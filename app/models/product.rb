class Product < ActiveRecord::Base
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
  validates :title, :permalink, uniqueness: true


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

  def self.update_products_table
    import = File.read('xml/import.xml')
    doc = Nokogiri::XML(import)

    offers = Nokogiri::XML( File.read('xml/offers.xml') )

    if doc.at_css('Каталог').attribute('СодержитТолькоИзменения').value == 'true'
      doc.css('Товар').each do |product|
        item_id     = product.at_css('>Ид').try :content
        item        = product.at_css('>Артикул').try :content
        title       = product.at_css('>Наименование').try :content
        group_id    = product.at_css('>Группы>Ид').try :content
        description = product.at_css('>Описание').try :content
        producer    = product.at_css('>>Изготовитель>Наименование').try :content
        long_name   = product.at_xpath("ЗначенияРеквизитов/ЗначениеРеквизита[Наименование='Полное наименование']/Значение").try :content

        permalink   = title.mb_chars.parameterize('-')

        price = offers

        new_product =  Product.find_or_initialize_by(item_id: item_id)
        new_product.update(
          item:        item,
          title:       title,
          group_id:    group_id,
          description: description,
          producer:    producer,
          long_name:   long_name,
          permalink:   permalink
        )

      end
    end
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

  def self.generate_images
    images = joins{images}.each do |product|
      product.generate_images
    end

    puts "Images for #{images.length} products generated."
  end

  def generate_images
    if images.any?
      ext = '.jpg'
      prefix = 'public'
      path = '/catalog/' + group.parent.permalink + '/' + group.permalink + '/' + permalink + '/'
      FileUtils.makedirs prefix + path unless File.exists? prefix + path

      images.each_with_index do |img, i|
        image = MiniMagick::Image.open prefix + '/images/' + img.url, ext
        watermark = MiniMagick::Image.open(prefix + '/images/watermark.png', ext)
        index = '-' + (i+1).to_s.rjust(2, '0')

        original_url = path + permalink + index + ext
        image.resize '800'
        original = image.composite(watermark) do |i|
          i.geometry '+50+50'
        end
        original.write prefix + original_url
        img.original_url = original_url

        medium_url = path + 'medium-' + permalink + index + ext
        original.resize '300'
        original.write prefix + medium_url
        img.medium_url = medium_url

        thumbnail_url = path + 'thumb-' + permalink + index + ext
        image.resize '135'
        image.write prefix + thumbnail_url
        img.thumbnail_url = thumbnail_url

        img.save

        puts "Image for #{title} generated."
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
end