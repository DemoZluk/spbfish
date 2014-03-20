class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_one :information, dependent: :destroy

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

  validates :email, uniqueness: {case_sensitive: false}
  validates :email, presence: true

  def admin?
    group == 'admin'
  end

  def all_orders
    uid = id
    umail = email
    Order.where{(user_id == uid) | (email == umail)}
  end

end
