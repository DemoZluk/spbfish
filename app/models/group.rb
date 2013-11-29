class Group < ActiveRecord::Base
  belongs_to :parent, class_name: 'Group', foreign_key: :parent_id
  has_many :children, class_name: 'Group', foreign_key: :parent_id
  has_many :products

  validates :id, uniqueness: true

  self.primary_key = :id

  def to_param
    permalink
  end

  def properties
    item_ids = self.products.pluck(:item_id)
    property_ids = ProductPropertyValue.where{item_id >> item_ids}.uniq.pluck(:property_id)
    Property.uniq.where{id >> property_ids}.order(:title)
  end

  def producers
    self.all_products.uniq.pluck(:producer)
  end

  # If group has any children, join products, groups and their parents
  def all_products(order = 'title')
    ids = self.ids_including_children
    Product.where{group_id >> ids}.order(order)
  end

  def ids_including_children
    group_id = self.id
    ids = []
    ids << group_id
    ids << Group.where{parent_id == group_id}.pluck(:id) if self.children.any?
    ids.flatten.uniq
  end
end