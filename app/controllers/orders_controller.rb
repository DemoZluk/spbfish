class OrdersController < ApplicationController
  include Redirect
  include CurrentCart
  before_action :set_cart, only: [:new, :create]
  before_action :set_order, except: [:index, :new, :create, :multiple_orders]
  before_action :check_if_order_empty, only: [:edit]
  before_action :check_if_cart_empty, only: [:new, :create]
  skip_before_action :authenticate_user!, only: [:show]

  layout 'simple', only: :print_preview

  #layout false, only: [:check, :payment]
  # GET /orders
  # GET /orders.json
  def index
    authorize! :index, Order
    @controller = controller_name
    @orders = Order.accessible_by(current_ability).order('created_at DESC').page(params[:page])
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @line_items = @order.line_items.page(params[:page])
  end

  # GET /orders/new
  def new
    @page_title = 'Оформление заказа'
    if user_signed_in?
      info = Hash(current_user.information.try(:attributes))
      info[:email] = current_user.email
      @order = Order.new(name: info[:shipping_name], address: info[:shipping_address], phone_number: info[:shipping_phone])
    else
      @order = Order.new
    end
  end

  # GET /orders/1/edit
  def edit
    @cart = @order
    @line_items = @order.line_items.page(params[:page])
  end

  # POST /orders
  # POST /orders.json
  def create
    params = order_params
    if user_signed_in?
      if params[:remember]
        info = Information.find_or_create_by(user_id: current_user.id)
        info.update order_params.slice(*Information.column_names)
      end
    end

    @order = Order.new(params)
    @order.user_id = @cart.user_id
    respond_to do |format|
      if @order.save && @order.add_line_items_from_cart(@cart)
        @order.state = 'Активен'

        # if @order.pay_type == 'Наличный'
        #   type = 'cash'
        #   message = 'Вы выбрали наличный расчёт, с вами свяжется менеджер для согласования и подтверждения заказа. Вы сможете его оплатить наличными средствами при получнеии.'
        # elsif @order.pay_type == 'Безналичный'
        #   type = 'noncash'
        #   message = 'Вы выбрали безналичный расчёт, с вами свяжется менеджер для согласования и подтверждения заказа. После подтверждения в письме вам придет ссылка, пройдя по которой, вы попадёте на страницу с формой оплаты.'
        # else
        #   redirect_to store_url, flash: {error: 'Способ оплаты не определён'} and return
        # end
        format.html { redirect_to order_url(@order, t: @order.token), flash: {success: message || I18n.t(:order_thanks)} }
        format.json { render state: :created, location: @order }
        OrderNotifier.received(@order).deliver
        OrderNotifier.order(@order).deliver
        Cart.destroy(session[:cart_id])
        session[:cart_id] = nil
      else
        format.html { render action: 'new'}
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_by_item
    if product = Product.find_by(item: params[:item])
      prod_attr = product.attributes.slice('id', 'price')

      @order = Cart.find(params[:id]) unless controller_name == 'orders'

      li = @order.line_items.find_or_initialize_by(product_id: prod_attr['id'])
      li.price = prod_attr['price']
      li.quantity += (params[:qt] || 1).to_i
      if li.save
        redirect_to :back, notice: "#{product.title} добавлен в этот заказ"
      end
    else
      redirect_to :back, notice: 'Товар с таким артикулом не найден'
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    authorize! :update, @order
    respond_to do |format|
      @old_lis = @order.line_items

      redirect_to_back_or_default notice: I18n.t(:cart_is_empty) and return if @order.line_items.empty?

      if @order.update(order_params)
        @cart = @order
        format.html { redirect_to @order, notice: 'Параметры заказа обновлены' }
        format.json { head :no_content }
        OrderNotifier.update(@old_lis, @order).deliver
      else
        @cart = @order
        format.html { render action: 'edit' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    authorize! :destroy, Order
    @order.try(:destroy)
    respond_to do |format|
      format.html { redirect_to store_url, flash: { warning: "Заказ № #{@order.id} удалён"} }
      format.js { flash.now[:notice] = "Заказ № #{@order.id} удалён"; render 'orders/change_order.js' }
      format.json { head :no_content }
    end
  end

  # Confirmation of order by manager
  def confirm
    authorize! :confirm, Order
    if @order.token == params[:token] && @order.update_columns(confirmed_at: DateTime.now) && (@order.state = 'Подтверждён') && OrderNotifier.confirmed(@order).deliver
      respond_to do |format|
        format.html { redirect_to_back_or_default flash: { success: "Заказ № #{@order.id} подтверждён"} }
        format.js { flash.now[:success] = "Заказ № #{@order.id} подтверждён"; render 'orders/change_order.js' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to_back_or_default flash: {error: 'Произошла ошибка. Попробоуйте позднее.'} }
        format.js { flash.now[:error] = 'Произошла ошибка. Попробоуйте позднее.'; render 'orders/change_order.js' }
        format.json { render json: {message: 'Произошла ошибка. Попробоуйте позднее.'} }
      end
    end
  end

  def print
    authorize! :print, @order
  end

  def print_preview
    authorize! :print, @order
    @page_title = "Печать заказа №#{@order.id}"
    @discount = params[:discount].to_i
    @shipping = params[:shipping].to_i
  end

  # def yandex_payment
  #   if @order.token == order_params[:token]
  #     if @order.confirmed?
  #       respond_to do |format|
  #         format.html
  #         format.js
  #         format.json { head :no_content }
  #       end
  #     else
  #       redirect_to_back_or_default flash: {error: "Заказ № #{@order.id} ещё не подтверждён."}
  #     end
  #   else
  #     redirect_to_back_or_default flash: {error: 'Ошибка! Неверный ключ.'}
  #   end
  # end

  # def check
  #   @params = payment_params
  #   if @order
  #     order_parameters = {}
  #     order_parameters[:action] = 'checkOrder'
  #     order_parameters[:orderSumAmount] = '%.2f' % @order.total_price
  #     order_parameters[:orderSumCurrencyPaycash] = '643'
  #     order_parameters[:orderSumBankPaycash] = '1001' #@params[:shopSumBankPaycash]
  #     order_parameters[:shopId] = '22081'
  #     order_parameters[:invoiceId] = @params[:invoiceId]
  #     order_parameters[:customerNumber] = @params[:customerNumber] || ''
  #     order_parameters[:shopPassword] = 'fishMarkt'

  #     md5 = Digest::MD5.hexdigest(order_parameters.values.join(';')).upcase

  #     @code = 200

  #     if md5 == @params[:md5].upcase
  #       @code = 0
  #     else
  #       @code = 1
  #     end

  #     render 'orders/result.xml'
  #   else
  #     puts 'fail'
  #   end
  # end

  # def payment_success
  #   respond_to do |format|
  #     format.html { flash.now[:success] = 'Платеж успешно проведён' }
  #     format.json { render json: {message: 'Платеж успешно проведён'} }
  #   end
  # end

  # def payment_failure
  #   respond_to do |format|
  #     format.html { flash.now[:danger] = 'Платеж не проведён' }
  #     format.json { render json: {message: 'Платеж не проведён'} }
  #   end
  # end

  # def payment
  #   @params = payment_params
  #   if @order
  #     order_parameters = {}
  #     order_parameters[:action] = 'paymentAviso'
  #     order_parameters[:orderSumAmount] = '%.2f' % @order.total_price
  #     order_parameters[:orderSumCurrencyPaycash] = '643'
  #     order_parameters[:orderSumBankPaycash] = '1001' #@params[:shopSumBankPaycash]
  #     order_parameters[:shopId] = '22081'
  #     order_parameters[:invoiceId] = @params[:invoiceId]
  #     order_parameters[:customerNumber] = @params[:customerNumber] || ''
  #     order_parameters[:shopPassword] = 'fishMarkt'

  #     md5 = Digest::MD5.hexdigest(order_parameters.values.join(';')).upcase

  #     @code = 200

  #     if md5 == @params[:md5].upcase
  #       @code = 0
  #       @order.state = 'Оплачен'
  #       @order.update_attribute(:invoice_id, @params[:invoiceId])
  #       OrderNotifier.paid(@order, @params).deliver
  #     else
  #       @code = 1
  #     end


  #     render 'orders/payment.xml'
  #   else
  #     redirect_to '/payment_failure',  flash: {error: 'Предоставлены неизвестные параметры'}
  #   end
  # end

  def close
    authorize! :close, Order
    if (@order.state = 'Закрыт')
      respond_to do |format|
        format.html { redirect_to orders_url, flash: { warning: "Заказ № #{@order.id} закрыт"} }
        format.js {flash.now[:warning] = "Заказ № #{@order.id} закрыт"; render 'orders/change_order.js'}
        format.json { head :no_content }
      end
    end
  end

  def cancel
    authorize! :cancel, Order
    if (@order.state = 'Отменён') && (@order.update_columns(confirmed_at: nil))
      OrderNotifier.canceled(@order).deliver
      respond_to do |format|
        format.html { redirect_to orders_url, flash: { warning: "Заказ № #{@order.id} отменён"} }
        format.js {flash.now[:warning] = "Заказ № #{@order.id} отменён"; render 'orders/change_order.js'}
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to_back_or_default flash: { warning: "Не получилось отменть заказ №#{@order.id}"} }
        format.js { flash.now[:warning] = "Не получилось отменть заказ № #{@order.id}"; render 'orders/change_order.js' }
        format.json { render json: {status: 'error'} }
      end
    end
  end

  def repeat
    if @order.state = 'Активен'
      OrderNotifier.received(@order).deliver
      OrderNotifier.order(@order).deliver
      respond_to do |format|
        format.html { redirect_to_back_or_default flash: {success: 'Заказ заново размещён'} }
        format.js { flash.now[:success] = 'Заказ заново размещён'; render 'orders/change_order.js'}
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to_back_or_default flash: {success: 'Заказ не может быть заново размещён'} }
        format.js {render 'orders/change_order.js'}
        format.json { head :no_content }
      end
    end
  end

  def multiple_orders
    if params[:commit] == 'Удалить'
      authorize! :destroy, Order
      ids = params[:ids].map(&:to_i) if params[:ids]
      orders = Order.where{id >> ids}
      if orders.destroy_all
        redirect_to orders_url, notice: "Заказы #{ids} удалены"
      end
    else
      redirect_to orders_url, flash: {error: 'Неверно заданы параметры'}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @controller = Rails.application.routes.recognize_path(request.referrer)[:controller]
      @order = Order.find(payment_params[:orderNumber] || params[:id] || order_params[:id])
      @line_items = @order.line_items.page params[:page]
    rescue ActiveRecord::RecordNotFound
      redirect_to_back_or_default flash: {error: t('orders.show.no_such_order')}
    end

    def check_if_order_empty
      set_order
      redirect_to(store_url, notice: I18n.t('orders.show.order_is_empty')) if @order.line_items.empty?
    end

    def check_if_cart_empty
      redirect_to_back_or_default(notice: I18n.t(:cart_is_empty)) if @cart.line_items.empty?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:id, :name, :address, :token, :email, :shipping_type, :shipping_date, :phone_number, :comment)
    rescue ActionController::ParameterMissing
      {}
    end

    def payment_params
      params.permit(:performedDatetime, :paymentDatetime, :code, :shopId, :invoiceId, :orderSumAmount, :shopSumAmount, :shopSumBankPaycash, :message, :techMessage, :orderNumber, :md5, :customerNumber)
    end
end
