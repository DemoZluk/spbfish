class CartsController < ApplicationController
  include CurrentCart
  include Redirect

  before_action :set_cart, only: [:show, :create, :update, :clear]
  skip_before_action :authenticate_user!, only: [:create, :show, :update, :clear]
  rescue_from ActiveRecord::RecordNotFound, with: :invalid_cart

  load_and_authorize_resource

  # GET /carts
  # GET /carts.json
  def index
    @carts = Cart.not_empty.page(params[:page]).per(10)
  end

  # GET /carts/1
  # GET /carts/1.json
  def show
    @cart = @user_cart || @current_cart
    redirect_to cart_path, notice: 'Нет прав на просмотр этой корзины.' unless (current_user_owns?(@cart) || can?(:manage, Cart))
    @line_items = @cart.line_items.page(params[:page]).per(10)
  end

  # GET /carts/new
  def new
    @cart = Cart.new(user_id: current_user.try(:id))
  end

  # GET /carts/1/edit
  def edit
  end

  # POST /carts
  # POST /carts.json
  def create
    @cart = Cart.new(cart_params)
    respond_to do |format|
      if @cart.save
        format.html { redirect_to @cart, notice: 'Корзина создана.' }
        format.json { render action: 'show', status: :created, location: @cart }
      else
        format.html { render action: 'new' }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /carts/1
  # PATCH/PUT /carts/1.json
  def update
    @cart.line_items.each do |item|
      item.quantity = params[item.id.to_s.to_sym]
      item.save
    end
    respond_to do |format|
      if @cart.update(cart_params)
        format.html { redirect_to @cart, notice: 'Cart was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /carts/1
  # DELETE /carts/1.json
  def destroy
    @cart.destroy
    respond_to do |format|
      format.html { redirect_to_back_or_default }
      format.js
      format.json { head :no_content }
    end
  end

  def clear
    @cart.line_items.destroy_all
    respond_to do |format|
      format.html { redirect_to_back_or_default }
      format.js
      format.json { head :no_content }
    end
  end

  def merge_yes
    if user_signed_in? && @old_cart
      cart = Cart.find_by(user_id: current_user.id)
      @old_cart.line_items.update_all cart_id: session[:cart_id]
      @old_cart.destroy
    end
    redirect_to_back_or_default
  end

  def merge_no
    @old_cart.destroy if @user && @old_cart
    redirect_to_back_or_default
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_cart
    #   @cart = Cart.find (params[:id] ? params[:id] : session[:cart_id])
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cart_params
      params[:cart]
    end

    def invalid_cart
      logger.error("Неправильно задана корзина #{params[:id]}")
      redirect_to(store_url, notice: 'Неверная корзина')
    end

    def current_user_owns? cart
      Cart.find(session[:cart_id]) == cart
    end

end
