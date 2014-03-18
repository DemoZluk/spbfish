class LineItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
  belongs_to :cart, touch: true
  validates :quantity, inclusion: 0..999

  def total_price
    product.price * quantity
  end
end
