#encoding: utf-8
class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :new, :create]
  before_action :set_order, only: [:show, :edit, :update, :destroy, :check_if_empty, :cancel]
  before_action :check_if_empty, only: [:edit]
  #before_action :check_date, only: [:create, :update]

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @line_items = @order.line_items.page(params[:page])
  end

  # GET /orders/new
  def new
    if @cart.line_items.empty?
      redirect_to :back, notice: I18n.t(:cart_is_empty)
    end

    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    total_price = @cart.total_price
    p = order_params
    p.merge!(user_id: current_user.try(:id))
    p[:status] = 'Активен'
    @order = Order.new(p)
    @order.token = params[:authenticity_token]
    @order.add_line_items_from_cart(@cart)

    respond_to do |format|
      if @order.save
        format.html { redirect_to order_path(@order, t: @order.token), flash: {order_created: I18n.t(:order_thanks)} }
        format.json { render action: 'show', status: :created,
        location: @order }
        OrderNotifier.received(@order, total_price).deliver
        OrderNotifier.order(@order, total_price).deliver
        Cart.destroy(session[:cart_id])
        session[:cart_id] = nil
      else
        format.html { render action: 'new' }
        format.json { render json: @order.errors,
        status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
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
    @order.destroy
    respond_to do |format|
      format.html { redirect_to :back, flash: { warning: "Заказ № #{number} удалён"} }
      format.json { head :no_content }
    end
  end

  def cancel
    number = @order.id
    @order.update_column(:status, 'Отменён')
    OrderNotifier.order_canceled(@order).deliver
    respond_to do |format|
      format.html { redirect_to :back, flash: { warning: "Заказ № #{number} отменён"} }
      format.json { head :no_content }
    end
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
end
