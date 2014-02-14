class Property < ActiveRecord::Base
  has_many :product_property_values
  has_many :values, through: :product_property_values

  validates :property_id, uniqueness: true, presence: true

  # self.primary_key = :property_id
end
