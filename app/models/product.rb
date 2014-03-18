class Product < ActiveRecord::Base
  belongs_to :group, touch: true

  has_many :line_items
  has_many :orders, through: :line_items
  has_many :images, primary_key: :item_id, foreign_key: :item_id
  has_many :product_property_values
  has_many :properties, through: :product_property_values
  has_many :values, through: :product_property_values

  before_destroy :ensure_not_referenced_by_any_line_item

  validates :title, :description, presence: true
  validates :price, numericality: {greater_than_or_equal_to: 0.00}
  validates :title, uniqueness: true

  def to_param
    permalink
  end

  def self.with_price
    where{price > 0}
  end
  
  def self.latest
    Product.order('updated_at').last
  end

  def rate(points)
    if [1, 2, 3, 4, 5].include?(points.to_i)
      rt = self.rating || 0
      rc = self.rating_counter || 0

      self.update_column :rating, (rt * rc + points.to_i) / (rc + 1)
      self.update_column :rating_counter, rc + 1
    else
      return false
    end
  end

  def image_url(item_id)
    images.where(item_id: item_id)
  end

  def desc
    if self.description == '.'
      long_name
    else
      self.description
    end
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