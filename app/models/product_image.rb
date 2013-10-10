class ProductImage < ActiveRecord::Base
  belongs_to :product

  validates :item_id, presence: true
  validates :image_url, presence: true, uniqueness: true
end
