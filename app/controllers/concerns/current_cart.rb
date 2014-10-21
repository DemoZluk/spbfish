module CurrentCart
  extend ActiveSupport::Concern

  private

    def set_cart
      @current_cart = Cart.find session[:cart_id]
      if params[:cid] && can?(:manage, Cart)
        @user_cart = Cart.find params[:cid]
      end
      @cart = @user_cart || @current_cart
      @line_items = @cart.line_items.page(params[:page])
    rescue ActiveRecord::RecordNotFound
      @current_cart = Cart.create(user_id: current_user.try(:id))
      session[:cart_id] = @current_cart.id
    end

    def old_cart
      @user = User.find session[:user][:id] if session[:user]
      @old_cart = @user.carts.last
    end

end