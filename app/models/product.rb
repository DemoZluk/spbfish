class Product < ActiveRecord::Base
  include ProductModule

  belongs_to :group

  has_many :line_items
  has_many :orders, through: :line_items
  has_many :images
  has_many :product_property_values
  has_many :properties, through: :product_property_values
  has_many :values, -> { order 'product_property_values.property_id' }, through: :product_property_values
  has_many :ratings
  has_many :storages
  has_many :bookmarks
  has_many :users, through: :bookmarks

  before_destroy :ensure_not_referenced_by_any_line_item

  validates :title, :long_name, :permalink, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0.00 }
  validates :title, :permalink, :item_id, uniqueness: true

  scope :with_price, -> { where{price > 0} }


  def to_param
    permalink
  end

  def thumb
    images.order(:thumbnail_url).first.thumbnail_url
  rescue NoMethodError
    '/images/no_photo.png'
  end

  def medium
    images.order(:medium_url).first.medium_url
  rescue NoMethodError
    '/images/no_photo.png'
  end

  def desc
    if description == '.' || description == ''
      long_name
    else
      description
    end
  end

  def image_url
    images.order(:original_url).first.original_url
  rescue NoMethodError
    '/images/no_photo.png'
  end

  def self.latest
    Product.order('updated_at').last
  end

  def self.min_price
    minimum(:price).floor
  end

  def self.max_price
    maximum(:price).ceil
  end

  def avg_rating
    if ratings.any?
      ratings.to_a.sum(&:value)/ratings.count.to_f
    else
      0
    end
  end

  def self.search(query)
    string = [query, ActiveSupport::Inflector.transliterate(query)].map{|s| "%#{s.gsub('+', ' ').gsub('*', '%')}%"}
    self.where{
      (title.like_any string) |
      (long_name.like_any string) |
      (description.like_any string) |
      (item.like_any string)
    }
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
end