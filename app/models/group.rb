class Group < ActiveRecord::Base
  belongs_to :parent, class_name: 'Group', foreign_key: :parent_id
  has_many :children, class_name: 'Group', foreign_key: :parent_id
  has_many :products
  has_many :child_products, through: :children, source: :products

  validates :id, uniqueness: true

  self.primary_key = :id

  def to_param
    permalink
  end
end
