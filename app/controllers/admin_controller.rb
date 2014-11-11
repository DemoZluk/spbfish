class AdminController < ApplicationController
  skip_before_action :set_cart
  def index
    if current_user.admin?
      @carts = Cart.all.page(params[:page])
      @orders = Order.all.page(params[:page])
      @users = User.all.page(params[:page])
    else
      redirect_to store_path, notice: t(:not_admin)
    end
  end
end
