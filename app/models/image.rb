class Image < ActiveRecord::Base
  belongs_to :product

  validates :item_id, presence: true
  validates :url, presence: true, uniqueness: true
end
