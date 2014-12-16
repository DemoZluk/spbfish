module OrdersHelper
  def discount sum, discount
    number_with_precision (sum * (1 - (discount.to_f / 100))).floor, precision: 1
  end
end
