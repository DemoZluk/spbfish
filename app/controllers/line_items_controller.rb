#encoding: utf-8
class LineItemsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create, :decrement, :increment, :destroy]
  include CurrentCart
  before_action :set_cart, only: [:index, :create, :destroy, :decrement, :increment]
  before_action :set_line_item, only: [:show, :edit, :update, :destroy, :decrement, :increment]

  # GET /line_items
  # GET /line_items.json
  def index
    @line_items = LineItem.page(params[:page])
  end

  # GET /line_items/1
  # GET /line_items/1.json
  def show
  end

  # GET /line_items/new
  def new
    @line_item = LineItem.new
  end

  # GET /line_items/1/edit
  def edit
  end

  # POST /line_items
  # POST /line_items.json
  def create
    product = Product.find_by(permalink: params[:product_id])
    @line_item = @cart.add_product(product.id)

    respond_to do |format|
      if @line_item.save
        format.html { redirect_to store_url }
        format.js { @current_item = @line_item }
        format.json { render action: 'show', status: :created, location: @line_item }
      else
        format.html { render action: 'new' }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /line_items/1
  # PATCH/PUT /line_items/1.json
  def update
    respond_to do |format|
      if @line_item.update(line_item_params)
        format.html { redirect_to @line_item, notice: 'Line item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /line_items/1
  # DELETE /line_items/1.json
  def destroy
    @line_item.destroy
    respond_to do |format|
      format.html do
        if LineItem.all.length > 0 then
          redirect_to cart_url(session[:cart_id], notice: 'Удалён')
        else
          redirect_to store_url
        end
      end
      format.js {@current_item = @line_item}
      format.json { head :no_content }
    end
  end

  def decrement
    if @line_item.try(:quantity) > 1
      @line_item.quantity -= 1
      #redirect_to(cart_path(session[:cart_id]), notice: 'Product decremented successfully')
    else
      @line_item.destroy
    end

    if @line_item.save
      respond_to do |format|
        format.html {redirect_to cart_path(session[:cart_id])}
        format.js {@current_item = @line_item}
        format.json { head :no_content }
      end
    else
      invalid_line_item
    end
  end

  def increment
    if @line_item
      @line_item.quantity += 1
    else
      invalid_line_item
    end

    if @line_item.save
      respond_to do |format|
        format.html {redirect_to cart_path(session[:cart_id])}
        format.js {@current_item = @line_item}
        format.json { head :no_content }
      end
    else
      invalid_line_item
    end
  end

  def invalid_line_item
    logger.error("Позиции не существует")
    redirect_to(cart_path, notice: 'Позиции не существует')
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_line_item
      @line_item = LineItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def line_item_params
      params.require(:line_item).premit(:quantity)
    end
end
