class StoreController < ApplicationController
  include CurrentSettings
  include CurrentCart

  before_action :change_user_prefs, :set_products, :set_cart
  skip_before_action :authenticate_user!

  def visit_counter
    session[:counter] = (session[:counter]||0)+1
  end

  def index
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

    def set_products
      products = Product.with_price
      products = products.order(@order_by) if @order_by
      current_list_of products
    end
end
