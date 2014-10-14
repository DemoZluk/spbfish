module ProductModule
  extend ActiveSupport::Concern

  module ClassMethods

    def prefix
      "##{Time.now.to_s(:time)}: "
    end

    def update_products_table
      document = Nokogiri::XML( File.read('xml/import.xml') )

      puts "#{prefix}Начинаем выгрузку..."

      if document.at_css('Каталог').attribute('СодержитТолькоИзменения').value == 'true'
        update_partially(document)
      else
        update_all_products(document)
      end

      puts "#{prefix}Выгрузка завершена"
    end

    def generate_images
      counter = 0
      images = joins{images}.each do |product|
        counter += 1 if product.generate_images
      end

      puts "Images for #{counter} products generated."
    end

    private

      def update_partially1(document)
        #puts "#{prefix}Обновляем частично..."

        document.css('Товар').each do |product|

          new_product = make_product product

          if tmp_product = Product.find_by(item_id: product.at_css('>Ид').try(:content))

            unless tmp_product.slice(\
              'item_id',\
              'item',\
              'title',\
              'group_id',\
              'description',\
              'producer',\
              'long_name',\
              'price') == new_product
              #puts "Обновляем #{tmp_product['title']}..."
              tmp_product.update!(new_product)
            end

          end
          # update_or_create_from_xml(new_product)
        end
      end

      def update_partially(document)
        puts "#{prefix}Обновляем частично..."
        counter = 0

        document.css('Товар').first(50).each do |product|

          changed = false
          new_product = make_product product
          item_id = product.at_css('>Ид').try(:content)

          if tmp_product = Product.find_by(item_id: item_id)

            diff = {}
            tmp_product.slice(\
              'item_id',\
              'item',\
              'title',\
              'group_id',\
              'description',\
              'producer',\
              'long_name',\
              'price').each {|k, v| diff[k] = new_product[k] unless new_product[k] == v}

            if diff.empty?
              #puts "#{new_product['title']}: товар не изменен"
            else
              puts "#{tmp_product['title']}: #{diff}"
              tmp_product.update! diff
              changed = true
            end

            changed = true unless tmp_product.images_equal_to?(product) == true

          end


          counter += 1 if changed == true
          # update_or_create_from_xml(new_product)
        end

        puts "#{prefix}Товаров изменено: #{counter}"
      end

      def update_all_products(document)
        puts "#{prefix}Обновляем полностью..."
      end

      def make_product product
        item_id = product.at_css('>Ид').try(:content)

        offers   = Nokogiri::XML( File.read('xml/offers.xml') )
        if offer = offers.at_xpath("//Предложение[Ид='#{item_id}']")
          price = offer.at_xpath('.//ЦенаЗаЕдиницу').content.to_f
        else
          #puts "Цена не указана..."
          price = 0
        end

        title = product.at_css('>Наименование').try(:content)
        permalink = title.mb_chars.parameterize('-')

        {
          "item_id"     => item_id,
          "item"        => product.at_css('>Артикул').try(:content),
          "title"       => title,
          "group_id"    => product.at_css('>Группы>Ид').try(:content),
          "description" => product.at_css('>Описание').try(:content),
          "producer"    => product.at_css('>Изготовитель>Наименование').try(:content),
          "long_name"   => product.at_xpath("ЗначенияРеквизитов/ЗначениеРеквизита[Наименование='Полное наименование']/Значение").try(:content),
          "price"       => price,
          "permalink"   => permalink
        }
      end

      def update_or_create_from_xml product

        permalink   = product['title'].mb_chars.parameterize('-')

        new_product = Product.find_or_initialize_by(item_id: product['item_id'], permalink: permalink)
        new_product.update(product)

      end

  end

  def generate_images(silent = true)
    if images.any?
      ext = '.jpg'
      prefix = 'public'
      # path = '/catalog/' + group.parent.permalink + '/' + group.permalink + '/' + permalink + '/'
      path = "/catalog/#{group.permalink}/#{permalink}/"
      FileUtils.makedirs prefix + path unless File.exists? prefix + path

      images.each_with_index do |img, i|
        image = MiniMagick::Image.open prefix + '/images/' + img.url, ext
        watermark = MiniMagick::Image.open(prefix + '/images/watermark.png', ext)
        index = '-' + (i+1).to_s.rjust(2, '0')

        original_url = path + permalink + index + ext
        image.resize '800'
        original = image.composite(watermark) do |i|
          i.gravity 'Center'
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

        puts "Image for #{title} generated." unless silent
      end

      return true
    else
      return false
    end
  end

  def images_equal_to? new_product
    new_images = new_product.css('>Картинка').map(&:text)
    old_images = images.map(&:url)
    if new_images == old_images
      true
    else
      images.each_with_index do |img, i|
        puts "#{img.url} -> #{new_images[i]}"
        img.update!(url: new_images[i])
      end
      generate_images
      false
    end

  end


end
