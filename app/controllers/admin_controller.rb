class AdminController < ApplicationController
  def index
    if User.find(session[:user_id]).try(:user_group) == 'admin'
      @carts = Cart.all
      @orders = Order.all
      @users = User.all
    else
      redirect_to store_url
    end
  end
end
