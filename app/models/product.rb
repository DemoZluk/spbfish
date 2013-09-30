#encoding: utf-8
class Product < ActiveRecord::Base
  has_many :product_images

  belongs_to :product_group

  has_many :line_items
  has_many :orders, through: :line_items

  before_destroy :ensure_not_referenced_by_any_line_item

  validates :title, :description, presence: true
  validates :price, numericality: {greater_than_or_equal_to: 0.01}
  validates :title, uniqueness: true

  def to_param
    permalink
  end
  
  def self.latest
    Product.order('updated_at').last
  end

  def rate (points, product_id)
    product = Product.find(product_id)
    rt = product.rating || 0
    rc = product.rating_counter || 0
    product.rating = (rt * rc + points.to_i) / (rc + 1)
    product.rating_counter = rc + 1
    product.save
  end

  private

    # ensure that there are no line items referencing this product
    def ensure_not_referenced_by_any_line_item
      if line_items.empty?
        return true
      else
        errors.add(:base, 'Line Items present')
        return false
      end
    end
    
  # !!!!!!!!!!!!
  # !!! TODO !!!
  # !!!!!!!!!!!!
  #
  # Add thumbnails later!
end