class ProductGroups < ActiveRecord::Base
  belongs_to :parent, class_name: 'ProductGroups', foreign_key: :parent_id
  has_many :children, class_name: 'ProductGroups', foreign_key: :parent_id
  has_many :products, foreign_key: :group_id

  validates :id, uniqueness: true

  self.primary_key = :id

  def to_param
    permalink
  end
end
