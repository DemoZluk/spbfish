class AdminController < ApplicationController
  skip_before_action :set_cart
  def index
    if current_user.admin?
      @carts = Cart.all
      @orders = Order.all
      @users = User.all
    else
      redirect_to store_path, notice: t(:not_admin)
    end
  end
end
