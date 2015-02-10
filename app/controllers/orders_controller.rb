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
    if user_signed_in? && current_user.information
      info = Hash(current_user.information.attributes).with_indifferent_access
      info[:email] = current_user.email
      puts info
      @order = Order.new(email: current_user.email, name: info[:shipping_name], address: info[:shipping_address], phone_number: info[:shipping_phone])
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
    if user_signed_in? && params[:remember]
      info = Information.find_or_create_by(user_id: current_user.id)
      info.update shipping_name: order_params[:name], shipping_address: order_params[:address], shipping_phone: order_params[:phone_number]
    end

    @order = Order.new(order_params)
    @order.user_id = @cart.user_id
    respond_to do |format|
      if @order.save && @order.add_line_items_from_cart(@cart)
        @order.state = 'Активен'

        format.html { redirect_to order_url(@order, t: @order.token), flash: {success: I18n.t(:order_thanks)} }
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
  # def confirm
  #   authorize! :confirm, Order
  #   if @order.token == params[:token] && @order.update_columns(confirmed_at: DateTime.now) && (@order.state = 'Подтверждён') && OrderNotifier.confirmed(@order).deliver
  #     respond_to do |format|
  #       format.html { redirect_to_back_or_default flash: { success: "Заказ № #{@order.id} подтверждён"} }
  #       format.js { flash.now[:success] = "Заказ № #{@order.id} подтверждён"; render 'orders/change_order.js' }
  #       format.json { head :no_content }
  #     end
  #   else
  #     respond_to do |format|
  #       format.html { redirect_to_back_or_default flash: {error: 'Произошла ошибка. Попробоуйте позднее.'} }
  #       format.js { flash.now[:error] = 'Произошла ошибка. Попробоуйте позднее.'; render 'orders/change_order.js' }
  #       format.json { render json: {message: 'Произошла ошибка. Попробоуйте позднее.'} }
  #     end
  #   end
  # end

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
      @order = Order.find(params[:id] || order_params[:id])
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

end
