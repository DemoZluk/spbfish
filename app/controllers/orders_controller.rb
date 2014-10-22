class OrdersController < ApplicationController
  include Redirect
  include CurrentCart
  before_action :set_cart, only: [:new, :create]
  before_action :set_order, except: [:index, :new, :delete_multiple_orders, :check, :payment]
  before_action :check_if_empty, only: [:edit]
  skip_before_action :authenticate_user!, only: [:show, :new, :create, :check, :payment]
  skip_before_action :verify_authenticity_token, only: [:check, :payment]

  #layout false, only: [:check, :payment]
  # GET /orders
  # GET /orders.json
  def index
    authorize! :read, Order
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @line_items = @order.line_items.page(params[:page])
  end

  # GET /orders/new
  def new
    @page_title = 'Оформление заказа'
    if @cart.line_items.empty?
      redirect_to_back_or_default notice: I18n.t(:cart_is_empty)
    end
    if user_signed_in?
      info = {email: current_user.email}.merge(Hash(current_user.information.try(:attributes)))
      @order = Order.new(info)
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
      info.update order_params.slice(*Information.column_names)
    end
    p = order_params.merge(user_id: current_user.try(:id), status: 'Активен')
    @order = Order.new(p)
    @order.token = params[:authenticity_token]
    unless @order.add_line_items_from_cart(@cart)
      redirect_to store_url, flash: {warning: t('orders.show.order_is_empty')} and return
    end
    total_price = @order.total_price

    respond_to do |format|
      if @order.save
        if order_params[:pay_type] == 'Наличный'
          path = order_path(@order, t: @order.token)
          type = 'cash'
        elsif order_params[:pay_type] == 'Безналичный'
          path = order_path(@order, t: @order.token)
          type = 'noncash'
        end
        format.html { redirect_to path, flash: {success: I18n.t(:order_thanks)} }
        format.json { render action: type, status: :created,
        location: @order }
        OrderNotifier.received(@order, total_price).deliver
        OrderNotifier.order(@order, total_price).deliver
        Cart.destroy(session[:cart_id])
        session[:cart_id] = nil
      else
        format.html { render action: 'new', anchor: 'info', notice: @order.errors}
        format.json { render json: @order.errors,
        status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      @old = @order
      total_price = @cart.total_price

      redirect_to_back_or_default notice: I18n.t(:cart_is_empty) and return if @order.line_items.empty?

      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Параметры заказа обновлены' }
        format.json { head :no_content }
        OrderNotifier.update(@old, @order, total_price).deliver
      else
        format.html { render action: 'edit' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    number = @order.id
    @order.try(:destroy)
    respond_to do |format|
      format.html { redirect_to_back_or_default flash: { warning: "Заказ № #{number} удалён"} }
      format.json { head :no_content }
    end
  end

  # Confirmation of order by manager
  def confirm
    
  end

  def check
    @params = payment_params
    render 'orders/result.xml'
  end

  def payment
    if params[:status] == 'success'
      render template: 'orders/payment_success'
    elsif params[:status] == 'failure'
      render template: 'orders/payment_failure'
    else
      redirect_to root_url, flash: {error: 'Неизвестная ошибка'}
    end
  end

  def cancel
    number = @order.id
    @order.update_column(:status, 'Отменён')
    OrderNotifier.order_canceled(@order).deliver
    respond_to do |format|
      format.html { redirect_to_back_or_default flash: { warning: "Заказ № #{number} отменён"} }
      format.json { head :no_content }
    end
  end

  def delete_multiple_orders
    ids = params[:ids]
    @orders = Order.where{id >> ids}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to store_path, notice: t('.no_such_order')
    end

    def check_if_empty
      order = Order.find(params[:id])
      redirect_to(store_path, notice: t('.order_is_empty')) if order.line_items.empty?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:name, :address, :email, :pay_type, :shipping_date, :phone_number, :comment)
    end

    def payment_params
      params.permit(:performedDatetime, :code, :shopId, :invoiceId, :orderSumAmount, :message, :techMessage)
    end
end
