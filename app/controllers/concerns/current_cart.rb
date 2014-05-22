module CurrentCart
  extend ActiveSupport::Concern
  
  private
  
    def set_cart
      @cart = Cart.find session[:cart_id]
      if user_signed_in? && current_user.admin?
        @cart = Cart.find params[:cid]
      end
    rescue ActiveRecord::RecordNotFound
      @cart = Cart.create(user_id: current_user.try(:id))
      session[:cart_id] = @cart.id
    end

    def old_cart
      @user = User.find session[:user][:id] if session[:user]
      @old_cart = @user.carts.last
    end

end