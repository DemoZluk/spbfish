class StoreController < ApplicationController
  #include CurrentCart
  skip_before_action :authorize

  def visit_counter
    session[:counter] = (session[:counter]||0)+1
  end

  def change_user_prefs
    per_page = params[:per_page]
    if per_page.to_i <= 250
      unless session && session[:user] && session[:user][:prefs]
        puts session[:user] = {user: {prefs: {}}}
      end
      session[:user][:prefs] = {per_page: per_page}
      redirect_to :back
    else
      redirect_to :back, notice: 'Too much results.'
    end
  end

  def index
    current = session[:user][:prefs][:per_page] rescue 10
    @products = Product.order(params[:order_by] || 'title').page(params[:page]).per(current)
  end
end
