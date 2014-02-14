#encoding: utf-8
class Order < ActiveRecord::Base
  has_many :line_items, dependent: :destroy
  belongs_to :user

  PAYMENT_TYPES = [ "Самовывоз", "Безналичный расчёт" ]
  validates :name, :address, :email, :shipping_date, presence: true
  validates :pay_type, inclusion: PAYMENT_TYPES
  validate :check_date

  def check_date
    if shipping_date.present? && (shipping_date < DateTime.tomorrow || shipping_date > DateTime.current+60)
      errors.add(:shipping_date, I18n.t(:please_enter_correct_date))
    end
  end

  def add_line_items_from_cart(cart)
    cart.line_items.each do |item|
      item.cart_id = nil
      line_items << item
    end
  end
end
