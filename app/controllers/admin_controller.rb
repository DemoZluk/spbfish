class AdminController < ApplicationController
  def index
    @carts = Cart.all
    @orders = Order.all
    @users = User.all
  end
end
