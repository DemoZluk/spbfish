class ProductPropertyValue < ActiveRecord::Base
  belongs_to :product
  belongs_to :property
  belongs_to :value
  has_many :vals, primary_key: :item_id, foreign_key: :item_id, class_name: 'ProductPropertyValue'
end