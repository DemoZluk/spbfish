class StoreController < ApplicationController
  include CurrentSettings

  before_action :change_user_prefs, :set_products
  skip_before_action :authorize

  def visit_counter
    session[:counter] = (session[:counter]||0)+1
  end

  def index
    respond_to do |format|
      format.html
      format.js {render template: 'shared/product_index'}
    end
  end

  private

    def set_products
      products = Product.where{price != 0}
      products = products.order(@order_by) if @order_by
      current_list_of products
    end
end
