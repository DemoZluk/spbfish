module CurrentCart
  extend ActiveSupport::Concern

  private

    def set_cart
      if params[:cid] && user_signed_in? && can?(:manage, @cart)
        @cart = Cart.find params[:cid]
      else
        @cart = Cart.find session[:cart_id]
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