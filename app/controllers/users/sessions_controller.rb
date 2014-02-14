class Users::SessionsController < Devise::SessionsController
  include CurrentCart
  before_action :set_cart, only: :create
  after_action :remember_user_id, :merge_carts?, only: :create

  def remember_user_id
    session[:user][:id] = @user.id
  end

  def merge_carts?
    puts '______________________________'
    if @old_cart = @user.carts.last
      flash[:merge_carts?] = t(:merge_carts?)
    end
    puts session[:user]
    Cart.find(session[:cart_id]).update user_id: session[:user][:id]
    puts '______________________________'
  end
end