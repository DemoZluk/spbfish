class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  require "highline/import"

  has_many :carts, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :ratings

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  has_many :bookmarks
  has_many :bookmarked_products, through: :bookmarks, source: :product

  has_many :subscriptions, primary_key: :email, foreign_key: :email
  has_many :mailers, through: :subscriptions

  has_one :information, dependent: :destroy

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

  #validates :email, uniqueness: {case_sensitive: false}
  validates :discount, numericality: { only_integer: true }, inclusion: { in: 0..100, message: 'Скидка должна быть в пределах от 0 до 100' }

  alias_method :info, :information


  def admin?
    role? 'admin'
  end

  def all_orders
    uid = id
    umail = email
    Order.where{(user_id == uid) | (email == umail)}
  end

  def owns?(object)
    object.try(:user) == self
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
      roles.pluck(:name)
    else
      if roles.find_by name: role
        true
      else
        answer = HighLine.ask("Role '#{role}' not found. Create new and assign to user? [y/n]: ")
        if answer.match(/y\w*/)
          Role.create(name: role)
          assign_role(role)
          true
        else
          false
        end
      end
    end
  end
end
