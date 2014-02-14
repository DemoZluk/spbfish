class Value < ActiveRecord::Base
  belongs_to :property
  has_many :product_property_values
  has_many :products, through: :product_property_values

  validates :value_id, uniqueness: true, presence: true

  scope :numerical, -> { where{value != nil} }
  scope :not_numerical, -> { where{value == nil} }
  scope :order_by_products_count, -> {
    joins{products}.group{values.id}.order{count(products.id).desc}.uniq
  }
end
