#encoding: utf-8
class Order < ActiveRecord::Base
  include Tokenable
  has_many :line_items, dependent: :destroy
  belongs_to :state
  belongs_to :user

  PAYMENT_TYPES = ['Наличный', 'Безналичный']
  validates :name, :email, :shipping_date, :phone_number, presence: true
  validates :address, presence: true, unless: 'pay_type == "Самовывоз"'
  validates :pay_type, presence: true, inclusion: PAYMENT_TYPES
  validates :comment, length: {maximum: 200}
  validate :check_date

  scope :active, -> { joins{state}.where{states.active == true} }
  scope :inactive, -> { joins{state.outer}.where{states.active >> [false, nil]} }

  def check_date
    if shipping_date.present? && (shipping_date < DateTime.tomorrow || shipping_date > DateTime.current+60)
      errors.add(:shipping_date, I18n.t(:please_enter_correct_date))
    end
  end

  def self.owned_by user
    if can? :index, Order
      all
    else
      find_by email: user.email
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
    line_items.to_a.sum { |item| item.total_price }
  end

  def confirmed?
    confirmed_at.present? && state? == 'Подтверждён'
  end

  def cash?
    pay_type == 'Наличный'
  end

  def noncash?
    pay_type == 'Безналичный'
  end

  def active?
    state.active?
  end
end
