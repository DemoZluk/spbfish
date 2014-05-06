#encoding: utf-8
class Order < ActiveRecord::Base
  include Tokenable
  has_many :line_items, dependent: :destroy
  belongs_to :user

  PAYMENT_TYPES = ['Наличный', 'Безналичный']
  ORDER_STATUS = [['Активен','В пути'],['Отменён','Закрыт']]
  validates :name, :email, :shipping_date, :phone_number, presence: true
  validates :address, presence: true, unless: 'pay_type == "Самовывоз"'
  validates :pay_type, inclusion: PAYMENT_TYPES
  validates :status, inclusion: ORDER_STATUS.flatten, allow_blank: true
  validates :comment, length: {maximum: 200}
  validate :check_date

  scope :active, -> { where{status >> ORDER_STATUS[0]} }
  scope :closed, -> { where{status >> ORDER_STATUS[1]} }

  def check_date
    if shipping_date.present? && (shipping_date < DateTime.tomorrow || shipping_date > DateTime.current+60)
      errors.add(:shipping_date, I18n.t(:please_enter_correct_date))
    end
  end

  def add_line_items_from_cart(cart)
    if cart.line_items.any?
      cart.line_items.each do |item|
        item.cart_id = nil
        line_items << item
      end
    else
      false
    end
  end

  def closed?
    ORDER_STATUS[1].include?(status)
  end

  def total_price
    line_items.to_a.sum { |item| item.total_price }
  end
end
