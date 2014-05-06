class Group < ActiveRecord::Base
  belongs_to :parent, class_name: 'Group', foreign_key: :parent_id, touch: true
  has_many :children, class_name: 'Group', foreign_key: :parent_id
  has_many :products

  validates :id, uniqueness: true

  self.primary_key = :id

  def to_param
    permalink
  end

  def parent_id
    permalink
  end

  def properties
    products.select('properties.*').joins{properties}.uniq
  end

  def producers
    all_products.uniq.pluck(:producer)
  end

  # If group has any children, join products, groups and their parents
  def all_products(order = 'title')
    ids = [id] << children.pluck(:id)
    Product.where{group_id >> ids}.order(order)
  end
end