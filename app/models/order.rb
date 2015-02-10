#encoding: utf-8
class Order < ActiveRecord::Base
  include Tokenable
  has_many :line_items, dependent: :destroy
  belongs_to :state
  belongs_to :user

  SHIPPING_TYPES = ['Доставка', 'Самовывоз']
  validates :name, :email, :phone_number, presence: true
  validates :address, presence: true, unless: 'shipping_type == "Самовывоз"'
  validates :shipping_type, presence: true, inclusion: SHIPPING_TYPES
  validates :comment, length: {maximum: 200}
  validate :check_date

  scope :active, -> { joins{state}.where{states.active == true} }
  scope :inactive, -> { joins{state.outer}.where{states.active >> [false, nil]} }
  scope :paid, -> { where{invoice_id} }

  def check_date
    if shipping_date.present? && (shipping_date < DateTime.tomorrow || shipping_date > DateTime.current+60)
      errors.add(:shipping_date, I18n.t(:please_enter_correct_date))
    end
  end

  def state= state
    if st = State.find_by(state: state)
      update_attribute :state_id, st.id
    else
      puts 'Не существует такого состояния заказа'
      return false
    end
  end

  def state?
    state.try(:state) || 'Не определён'
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
    state? == "Закрыт"
  end

  def total_price
    sum = line_items.to_a.sum(&:total_price)
    if user && user.discount.in?(1..99)
      sum * (1 - user.try(:discount).to_f/100)
    else
      sum
    end
  end

  def confirmed?
    confirmed_at.present? && state? == 'Подтверждён'
  end

  def active?
    state.active?
  end

  alias_method :discount_price, :total_price
end
