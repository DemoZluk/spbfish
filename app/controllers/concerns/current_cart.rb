module CurrentCart
  extend ActiveSupport::Concern
  
  private
  
    def set_cart
      @cart = Cart.find (((controller_name == 'carts') && params[:id]) ? params[:id] : session[:cart_id])
    rescue ActiveRecord::RecordNotFound
      @cart = Cart.create(user_id: (session[:user][:id] if session[:user]))
      puts session[:cart_id] = @cart.id
    end

    def old_cart
      @user = User.find session[:user][:id] if session[:user]
      @old_cart = @user.carts.last
    end

end