class Property < ActiveRecord::Base
  has_many :property_values

  validates :id, uniqueness: true, presence: true

  self.primary_key = :property_id
end
