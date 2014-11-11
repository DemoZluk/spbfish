class Users::SessionsController < Devise::SessionsController
  include CurrentCart
  before_action :set_cart, only: :create
  after_action :assign_cart, only: :create
  respond_to :html, :js

  def assign_cart
    @current_cart.update(user_id: current_user.id)
  end

  def merge_carts?
    if @old_cart = @user.carts.last
      flash[:merge_carts?] = t(:merge_carts?)
    end
    session[:user]
    Cart.find(session[:cart_id]).update user_id: current_user.id
  end
end