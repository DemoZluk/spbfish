class Property < ActiveRecord::Base
  has_many :values

  validates :property_id, uniqueness: true, presence: true

  self.primary_key = :property_id
end
