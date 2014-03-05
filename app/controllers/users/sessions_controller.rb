class Users::SessionsController < Devise::SessionsController
  include CurrentCart
  before_action :set_cart, only: :create

  def merge_carts?
    if @old_cart = @user.carts.last
      flash[:merge_carts?] = t(:merge_carts?)
    end
    puts session[:user]
    Cart.find(session[:cart_id]).update user_id: current_user.id
  end
end