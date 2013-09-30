module CartsHelper
  def count_cart_elements
    sum = 0
    if @cart
      @cart.line_items.each do |item|
        sum += item.quantity
      end
    end
    sum
  end
end
