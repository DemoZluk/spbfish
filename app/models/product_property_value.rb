class ProductPropertyValue < ActiveRecord::Base
  belongs_to :product, primary_key: :item_id, foreign_key: :item_id
  belongs_to :property
  belongs_to :value, primary_key: :value_id
  has_many :vals, primary_key: :item_id, foreign_key: :item_id, class_name: 'ProductPropertyValue'
end