#encoding: utf-8
class Order < ActiveRecord::Base
  include Tokenable
  has_many :line_items, dependent: :destroy
  belongs_to :user

  PAYMENT_TYPES = ['Самовывоз', 'Доставка']
  ORDER_STATUS = ['Активен','В пути','Отменён','Закрыт']
  validates :name, :email, :shipping_date, presence: true
  validates :address, presence: true, unless: 'pay_type == "Самовывоз"'
  validates :pay_type, inclusion: PAYMENT_TYPES
  validates :status, inclusion: PAYMENT_TYPES
  validates :comment, length: {maximum: 50}
  validate :check_date

  scope :active, -> { where{status >> ['Активен', 'В пути']} }
  scope :closed, -> { where{status >> ['Закрыт']} }

  def to_param
    token
  end

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

  def total_price
    line_items.to_a.sum { |item| item.total_price }
  end
end
