class Group < ActiveRecord::Base
  belongs_to :parent, class_name: 'Group', foreign_key: :parent_id
  has_many :children, class_name: 'Group', foreign_key: :parent_id
  has_many :products
  has_many :child_products, through: :children, source: :products
  has_many :properties, through: :products

  PRODUCERS = Product.uniq.pluck(:producer)

  validates :id, uniqueness: true
  validates :producer, inclusion: PRODUCERS

  self.primary_key = :id

  def to_param
    permalink
  end

  def producers
    self.all_products.map(&:producer).uniq
  end

  # If group has any children, recursively
  # get all products from all descendants
  def all_products(order = 'title')
    Product.joins(group: :parent).where("group_id = :id OR parents_groups.id = :id", {id: self.id}).uniq.order(order)
  end
end