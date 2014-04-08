module CartsHelper
  def count_cart_elements
    @cart.line_items.sum(&:quantity).to_s
  end

  def cart_owner?
    if (session[:cart_id] == params[:cid]) || can?(:edit, @cart)
      true
    else
      false
    end
  end
end
