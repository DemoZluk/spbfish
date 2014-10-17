module CartsHelper
  def count_cart_elements cart
    cart.try(:line_items).to_a.sum(&:quantity).to_s
  end

  def cart_owner?
    if (session[:cart_id] == params[:cid]) || can?(:edit, cart)
      true
    else
      false
    end
  end

  def grand_total cart
    if cart && !cart.line_items.empty?
      number_to_currency(cart.total_price)
    else
      'Пусто'
    end
  end
end
