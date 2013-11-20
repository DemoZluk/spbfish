class Product < ActiveRecord::Base
  belongs_to :group

  has_many :line_items
  has_many :orders, through: :line_items
  has_many :images, primary_key: :item_id, foreign_key: :item_id
  has_many :product_property_values, primary_key: :item_id, foreign_key: :item_id
  has_many :properties, foreign_key: :item_id, through: :product_property_values

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

  def rate(points, product)
    if [1, 2, 3, 4, 5].include?(points.to_i)
      rt = product.rating || 0
      rc = product.rating_counter || 0

      product.rating = (rt * rc + points.to_i) / (rc + 1)
      product.rating_counter = rc + 1

      product.save
    else
      return false
    end
  end

  def image_url(item_id)
    images.find_all_by_item_id(item_id)
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