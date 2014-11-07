module ProductModule
  extend ActiveSupport::Concern

  module ClassMethods

    def prefix
      "##{Time.now.to_s(:time)}: "
    end

    def update_products_table
      document = Nokogiri::XML( File.read('xml/import.xml') )

      puts "#{prefix}Начинаем выгрузку..."

      update_groups_and_properties(document.at_css('Классификатор'))
      update_products(document.at_css('Каталог'))

      puts "#{prefix}Выгрузка завершена."
    end

    def generate_images
      counter = 0
      images = joins{images}.each do |product|
        counter += 1 if product.generate_images
      end

      puts "Картинки для #{counter} товаров сгенерированы."
    end

    private

      def update_products document
        any_errors = false
        log_location = 'log/products_update.log'
        logger = Logger.new(log_location)
        logger.level = Logger::ERROR

        puts "#{prefix}Обновляем товары..."
        counter = 0
        offers = Nokogiri::XML( File.read('xml/offers.xml') ).at_css('Предложения')

        products = document.css('Товар')
        prod_progress = progress products.length

        products.each do |product|
          begin
            if offer = offers.at_xpath("//Предложение[Ид='#{product.at_css('>Ид').try(:content)}']")
              price = offer.at_xpath('.//ЦенаЗаЕдиницу').content.to_f
            else
              #puts "Цена не указана..."
              price = 0
            end

            changed = false
            new_product = make_product product, price
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
                logger.info "#{new_product['title']}: товар не изменен"
              else
                prod_progress.log "#{tmp_product['title']}: #{diff}"
                tmp_product.update! diff
                changed = true
              end
              changed = true unless tmp_product.images_equal_to?(product) == true
            else
              Product.create!(new_product)
            end
            prod_progress.increment
            counter += 1 if changed == true

          rescue ActiveRecord::RecordInvalid => error
            logger.error "#{error}: #{new_product['title']}"
            any_errors = true
          end
        end
        puts "#{prefix}Во время выгрузки товаров возникли ошибки. Подробности смотри в #{log_location}" if any_errors

        puts "#{prefix}Товаров изменено: #{counter}"
      end

      def make_product product, price
        item_id = product.at_css('>Ид').try(:content)

        title = product.at_css('>Наименование').try(:content)
        permalink = title.mb_chars.parameterize('-')

        { "item_id"     => item_id,
          "item"        => product.at_css('>Артикул').try(:content),
          "title"       => title,
          "group_id"    => product.at_css('>Группы>Ид').try(:content),
          "description" => product.at_css('>Описание').try(:content),
          "producer"    => product.at_css('>Изготовитель>Наименование').try(:content),
          "long_name"   => product.at_xpath("ЗначенияРеквизитов/ЗначениеРеквизита[Наименование='Полное наименование']/Значение").try(:content),
          "price"       => price,
          "permalink"   => permalink }
      end

      def update_groups_and_properties document
        puts "#{prefix}Обновляем группы и свойства товаров..."

        document.xpath('//Группы/descendant::Группа').each do |g|
          group_id = g.at_css('>Ид').try(:content)
          name = g.at_css('>Наименование').try(:content)
          if name.match(/^\d*\.\s.*/)
            title = name.split('. ')[1]
            priority = name.split('. ')[0]
          else
            title = name
            priority = nil
          end

          if parent = g.xpath('ancestor::Группа').last
            parent_name = parent.at_css('>Наименование').try(:content)
            parent_name = parent_name.split('. ')[1] if parent_name.match(/^\d*\.\s.*/)
            parent_id = parent.at_css('>Ид').try(:content)
            permalink = "#{parent_name.mb_chars.parameterize}/#{title.mb_chars.parameterize}"
          else
            parent_id = ''
            permalink = title.mb_chars.parameterize('-')
          end

          new_group = {title: title, parent_id: parent_id, permalink: permalink, priority: priority}

          if group = Group.find_by(id: group_id)
            group.update(new_group)
          else
            Group.create(new_group)
          end

        end

        properties = document.at_css('Свойства')
        val_progress = progress properties.css('Значение').length

        properties.css('Свойство').each do |prop|
          prop_id = prop.at_css('Ид').try(:content)
          title = prop.at_css('Наименование').try(:content)
          property = Property.find_or_initialize_by(property_id: prop_id)
          property.update(title: title)
          prop.css('>ВариантыЗначений>Справочник').each do |value|
            vt = value.at_css('Значение').try(:content)
            vid = value.at_css('ИдЗначения').try(:content)

            new_value = {property_id: property.id, title: vt, value: ((vt.split(' ')[0].match(/^\d+(.\d+)?$/)) ? vt.split(' ')[0].to_f : nil)}
            val = property.values.find_or_initialize_by(value_id: vid)
            val.update(new_value)

            val_progress.increment
          end
        end
      end

    def progress total
      ProgressBar.create(total: total, progress_mark: '█', format: "%P%%: |%B| %c of %C %E")
    end
  end

  def generate_images(silent = true)
    if images.any?
      # ext = '.jpg'
      # prefix = 'public'
      # puts path = "/catalog/#{group.permalink}/#{permalink}/"
      # FileUtils.makedirs prefix + path unless File.exists? prefix + path
      # FileUtils.rm_rf(Dir.glob(prefix + path + '*'))

      images.each_with_index do |img, i|
        index = ('-%02d' % i+1).to_s

        if new_image img.url, id, index
          puts "Image for #{title} generated." unless silent
        end
        # if File.exists?(prefix + '/images/' + img.url)
        #   image = MiniMagick::Image.open prefix + '/images/' + img.url, ext
        #   watermark = MiniMagick::Image.open(prefix + '/images/watermark.png', ext)
        #   index = '-' + (i+1).to_s.rjust(2, '0')

        #   puts original_url = path + permalink + index + ext
        #   image.resize '800'
        #   original = image.composite(watermark) do |i|
        #     i.gravity 'Center'
        #   end
        #   original.write prefix + original_url
        #   img.original_url = original_url

        #   medium_url = path + 'medium-' + permalink + index + ext
        #   original.resize '300'
        #   original.write prefix + medium_url
        #   img.medium_url = medium_url

        #   thumbnail_url = path + 'thumb-' + permalink + index + ext
        #   image.resize '135'
        #   image.write prefix + thumbnail_url
        #   img.thumbnail_url = thumbnail_url

        #   img.save
        #   puts img.attributes
        #   File.chmod 0644, prefix + original_url, prefix + medium_url, prefix + thumbnail_url

        # else
        #   puts "Файл картинки #{img.url} для #{title} отсутствует"
        # end
      end

      return true
    else
      return false
    end
  end

  def images_equal_to? new_product
    new_images = new_product.css('>Картинка').map(&:text)
    old_images = images.map(&:url)
    if new_images.empty? || new_images == old_images
      true
    else
      (old_images - new_images).each do |img|
        delete_image img
      end
      (new_images - old_images).each_with_index do |img, i|
        new_image img, id, i
      end
      #generate_images
      false
    end
  end

  def new_image url, pid, index = 0
    index = ('-%02d' % (index + 1)).to_s
    ext = '.jpg'
    prefix = 'public'
    path = "/catalog/#{group.permalink}/#{permalink}/"
    FileUtils.makedirs prefix + path unless File.exists? prefix + path
    FileUtils.rm_rf(Dir.glob(prefix + path + '*'))

    if File.exists?(prefix + '/images/' + url)
      image = MiniMagick::Image.open prefix + '/images/' + url, ext
      watermark = MiniMagick::Image.open(prefix + '/images/watermark.png', ext)

      original_url = path + permalink + index + ext
      image.resize '800'
      original = image.composite(watermark) do |i|
        i.gravity 'Center'
      end
      original.write prefix + original_url

      medium_url = "#{path}medium-#{permalink}#{index}#{ext}"
      original.resize '300'
      original.write prefix + medium_url

      thumbnail_url = "#{path}thumb-#{permalink}#{index}#{ext}"
      image.resize '135'
      image.write prefix + thumbnail_url

      File.chmod 0644, prefix + original_url, prefix + medium_url, prefix + thumbnail_url

      Image.create!(url: url, product_id: pid, original_url: original_url, medium_url: medium_url, thumbnail_url: thumbnail_url)
      return true
    else
      puts "Файл картинки #{url} для #{title} отсутствует"
      return false
    end
  end

  def delete_image url
    if img = Image.select('original_url, medium_url, thumbnail_url, id').find_by(url: url)
      #puts img.attributes.values.to_s
      img.attributes.values.first(3).select(&:present?).each do |i|
        File.delete "public/#{i}" if File.exists? "public/#{i}"
      end

      File.delete("public/images/#{url}") if File.exists? "public/images/#{url}"
      img.destroy!

    else
      puts "Image #{url} not found"
    end
  end


end
