class StoreController < ApplicationController
  #include CurrentCart
  #before_action :set_cart
  before_action :visit_counter, only: [:index]
  skip_before_action :authorize

  def visit_counter
    session[:counter] = (session[:counter]||0)+1
  end

  def index
    @products = Product.order(:title)
  end
end
