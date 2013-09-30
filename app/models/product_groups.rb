class ProductGroups < ActiveRecord::Base
  has_many :products
  
  validates :group_id, uniqueness: true
end
