class Product < ActiveRecord::Base
  belongs_to :group

  has_many :line_items
  has_many :orders, through: :line_items
  has_many :images
  has_many :product_property_values
  has_many :properties, through: :product_property_values
  has_many :values, through: :product_property_values
  has_many :ratings
  has_many :storages
  has_many :bookmarks
  has_many :users, through: :bookmarks

  before_destroy :ensure_not_referenced_by_any_line_item

  validates :title, :long_name, presence: true
  validates :price, numericality: {greater_than_or_equal_to: 0.00}
  validates :title, uniqueness: true


  def to_param
    permalink
  end

  def self.with_price
    where{price > 0}
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

  def image_url
    images.order(:original_url).first.original_url
  rescue NoMethodError
    '/images/no_photo.png'
  end

  def self.latest
    Product.order('updated_at').last
  end

  # def rate(points)
  #   if [1, 2, 3, 4, 5].include?(points.to_i)
  #     rt = self.rating || 0
  #     rc = self.rating_counter || 0

  #     self.update_column :rating, (rt * rc + points.to_i) / (rc + 1)
  #     self.update_column :rating_counter, rc + 1
  #   else
  #     return false
  #   end
  # end

  def desc
    if description == '.' || description == ''
      long_name
    else
      description
    end
  end

  def avg_rating
    if ratings.any?
      ratings.to_a.sum{|r| r.value}/ratings.count
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

  def create_images
    if images.any?
      ext = '.jpg'
      prefix = 'public/images'
      path = prefix + '/catalog/' + group.parent.permalink + '/' + group.permalink + '/' + permalink + '/'
      FileUtils.makedirs path unless File.exists? path

      images.each_with_index do |img, i|
        image = MiniMagick::Image.open prefix + '/' + img.url, ext
        watermark = MiniMagick::Image.open(prefix + '/watermark.png', ext)
        index = '-' + (i+1).to_s.rjust(2, '0')

        original_url = path + permalink + index + ext
        image.resize '800'
        original = image.composite(watermark) do |i|
          i.geometry '+50+50'
        end
        original.write original_url
        img.original_url = original_url.gsub(prefix, '')

        medium_url = path + 'medium-' + permalink + index + ext
        original.resize '300'
        original.write medium_url
        img.medium_url = medium_url.gsub(prefix, '')

        thumbnail_url = path + 'thumb-' + permalink + index + ext
        image.resize '135'
        image.write thumbnail_url
        img.thumbnail_url = thumbnail_url.gsub(prefix, '')

        img.save
      end
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