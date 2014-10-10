class Image < ActiveRecord::Base
  belongs_to :product

  validates :product_id, presence: true
  validates :url, presence: true
end
