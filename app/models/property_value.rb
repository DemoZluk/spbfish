class PropertyValue < ActiveRecord::Base
  belongs_to :property
  has_many :product_property_value,primary_key: :value_id, foreign_key: :value_id
  has_many :products, through: :product_property_value, foreign_key: :item_id

  validates :value_id, uniqueness: true, presence: true

  self.primary_key = :value_id
end
