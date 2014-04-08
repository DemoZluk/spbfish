class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :ratings
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  has_one :information, dependent: :destroy

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

  validates :email, uniqueness: {case_sensitive: false}
  validates :email, presence: true

  def admin?
    role? 'admin'
  end

  def all_orders
    uid = id
    umail = email
    Order.where{(user_id == uid) | (email == umail)}
  end

  def assign_role role
    r = Role.find_by(name: role)
    if r && UserRole.where(user_id: id, role_id: r.id).empty?
      UserRole.create(user_id: id, role_id: r.id)
    else
      false
    end
  end

  def resign_role role
    roles.find_by(name: role).destroy
  end

  def role? role = nil
    if role.nil?
      roles.pluck(:name).presence
    else
      if roles.find_by name: role
        true
      else
        false
      end
    end
  end

end
