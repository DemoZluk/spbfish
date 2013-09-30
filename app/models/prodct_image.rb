class ProdctImage < ActiveRecord::Base
  belongs_to :product

  validates :product_id, presence: true
  validates :image_id, presence: true, uniqueness: true
end
