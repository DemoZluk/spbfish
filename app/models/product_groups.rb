class ProductGroups < ActiveRecord::Base
  belongs_to :parent, class_name: 'ProductGroups', foreign_key: 'parent_id'
  has_many :child_groups, class_name: 'ProductGroups', foreign_key: 'parent_id'
  has_many :products, foreign_key: :group_id
  
  validates :group_id, uniqueness: true

  self.primary_key = :group_id
end
