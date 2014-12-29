class ProductsController < ApplicationController
  include Redirect
  include CurrentSettings
  include CurrentProducts

  load_and_authorize_resource except: [:show, :vote, :search]

  before_action :set_product, only: [:show, :edit, :update, :destroy, :vote]
  before_action :change_user_prefs, only: [:index, :search]

  skip_before_action :authenticate_user!, only: [:index, :show, :search]

  # GET /products
  # GET /products.json
  def index
    @products = current_list_of Product.accessible_by(current_ability)
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
    if can? :read, @product
      respond_to do |format|
        format.html
        format.js
      end
    else
      redirect_to store_url, notice: 'Нет доступа к данной странице'
    end
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { render action: 'new' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :no_content }
    end
  end

  def vote
    points = params[:points]
    pid = @product.id
    uid = current_user.id

    Rating.find_or_create_by(user_id: uid, product_id: pid).update(value: points)
  end

  def search
    if params[:q].size < 3
      redirect_to_back_or_default notice: t('.query_too_short') and return
    end
    @search_products = Product.with_price.search(params[:q])
    @products = current_list_of(@search_products).order(@order_by || 'title').page(params[:page]).per(@per_page)
    render template: 'store/index'
  end

  def who_bought
    @product = Product.find(params[:id])
    @latest_order = @product.orders.order('updated_at').last
    if stale?(@latest_order)
      respond_to do |format|
        format.atom
      end
    end
  end

  def force_update
    respond_to do |format|
      format.html
      format.json do
        output = capture(:stdout) do
          Rails.logger.level = 1
          Product.get_webdata
        end

        render json: {output: output.split("\n")}
      end
    end
  end

  def price
    @products = Product.all
    respond_to do |format|
      format.html
      format.xslx
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find_by(permalink: params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:title, :long_name, :description, :price, :html_keywords, :html_description)
    end
end
