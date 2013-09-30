class LineItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
  belongs_to :cart
  validates :quantity, inclusion: 0..50

  def total_price
    product.price * quantity
  end
end
