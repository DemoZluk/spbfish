#encoding: utf-8
class CartsController < ApplicationController
  include CurrentCart
  skip_before_action :authenticate_user!, only: [:create, :show, :update, :destroy]
  before_action :set_cart, only: [:show, :edit, :update, :destroy]
  before_action :set_user, :old_cart, only: [:merge_yes, :merge_no]
  after_action :cart_user_id, only: :create
  rescue_from ActiveRecord::RecordNotFound, with: :invalid_cart

  # GET /carts
  # GET /carts.json
  def index
    @carts = Cart.all
  end

  # GET /carts/1
  # GET /carts/1.json
  def show
  end

  # GET /carts/new
  def new
    @cart = Cart.new(user_id: (session[:user][:id] if session[:user]))
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
    session[:cart_id] = nil
    respond_to do |format|
      format.html { redirect_to store_url }
      format.js
      format.json { head :no_content }
    end
  end

  def merge_yes
    if @user && @old_cart
      cart = Cart.find session[:user][:id]
      @old_cart.line_items.update_all cart_id: session[:cart_id]
      @old_cart.destroy
    end
    redirect_to :back
  end

  def merge_no
    @old_cart.destroy if @user && @old_cart
    redirect_to :back
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_cart
    #   @cart = Cart.find (params[:id] ? params[:id] : session[:cart_id])
    # end

    def cart_user_id
      @cart.update user_id: session[:user][:id] if session[:user]
    end

    def set_user
      @user = User.find session[:user][:id] if session[:user]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cart_params
      puts params[:cart]
    end

    def invalid_cart
      logger.error("Неправильно задана корзина #{params[:id]}")
      redirect_to(store_url, notice: 'Неверная корзина')
    end

end
