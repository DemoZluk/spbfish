#encoding:utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
require "highline/import"

def main
  open_files
  create_groups
  create_properties
  create_products_and_values
  setup_prices
  add_values_to_values
  create_first_admin_user
end

def open_files
  import = File.read('xml/import.xml')
  @doc = Nokogiri::XML(import)

  @offers = File.read('xml/offers.xml')
end

def create_groups
  p "Creating groups"

  groups = @doc.xpath('//Группы/descendant::Группа')
  groups_progress = ProgressBar.create(total: groups.size, progress_mark: '█', format: "%P%%: |%B| %c of %C %E")
  groups.each do |g|
    parent = g.xpath('ancestor::Группа').last
    group_id = g.at_css('>Ид').content
    if parent
      parent_id = parent.at_css('>Ид').content
    else
      parent_id = ''
    end
    title = g.at_css('>Наименование').content
    permalink = title.mb_chars.parameterize('-') #.gsub(/[^-\wа-яА-ЯёЁ]+/i, ' ').squish.gsub(/\s+/, '_')
    Group.create(
      id: group_id,
      title: title,
      parent_id: parent_id,
      permalink: permalink
    )
    groups_progress.increment
  end

  p "End"
end

def create_properties
  p "Creating Properties"

  props = @doc.css('Свойство')
  props_progress = ProgressBar.create(total: props.size, progress_mark: '█', format: "%P%%: |%B| %c of %C %E")
  props.each do |p|
    id = p.at_css('Ид').content
    title = p.at_css('Наименование').content
    Property.create(
      property_id: id,
      title: title
    )

    p.css('ВариантыЗначений>Справочник').each do |v|
      Value.create(
        value_id: v.at_css('ИдЗначения').content,
        title: v.at_css('Значение').content,
        property_id: id
      )
    end
    props_progress.increment
  end

  p "End"  
end

def create_products_and_values
  p "Creating Products and Values"

  prods = @doc.css('Товар')
  prods_progress = ProgressBar.create(total: prods.size, progress_mark: '█', format: "%P%%: |%B| %c of %C %E")
  prods.each do |product|
    product_title = product.at_css('>Наименование').content
    permalink = product_title.mb_chars.parameterize('-') #.gsub(/[^-\wа-яА-ЯёЁ]+/i, ' ').squish.gsub(/\s+/, '_')

    if Product.find_by permalink: permalink
      prods_progress.log 'Товар ' + product_title + ' уже существует.'
    else
      item_id = product.at_css('>Ид').content

      p = Product.create!(
        item: product.at_css('>Артикул').content,
        title: product_title,
        long_name: product.at_xpath("ЗначенияРеквизитов/ЗначениеРеквизита[Наименование='Полное наименование']/Значение").content,
        description: product.at_css('>Описание').inner_html,
        producer: product.at_css('>Изготовитель>Наименование').content,
        item_id: item_id,
        price: 0,
        group_id: product.at_css('>Группы>Ид').content,
        permalink: permalink,
        rating: 0
      )

      offers = Nokogiri::XML(@offers)
      amount = offers.at_xpath("//Предложение[Ид='#{p.item_id}']/Количество").try(:content).to_f
      Storage.create!(
        product_id: p.id,
        amount: amount,
        unit: product.at_css('>БазоваяЕдиница').content
      )

      product.css('ЗначенияСвойства').each do |p|
        ProductPropertyValue.create(
          product_id: Product.find_by(item_id: item_id).id,
          property_id: Property.find_by(property_id: p.at_css('Ид').content).id,
          value_id: Value.find_by(value_id: p.at_css('Значение').content).try(:id)
        )

      #prods_progress.log 'Продукт ' + product_title + 'и его свойства добавлены в базу.'
      end

      product.css('Картинка').each do |img|
        Image.create(
          url: img.content,
          item_id: product.at_css('>Ид').content
        )
      end
    end

    prods_progress.increment
  end

  p "End"
end

def setup_prices
  puts "Setting prices"

  prices = Nokogiri::XML(@offers).css('Предложение')
  if prices.size > 0
    prices_progress = ProgressBar.create(total: prices.size, progress_mark: '█', format: "%P%%: |%B| %c of %C %E")
    prices.each do |offer|
      if product = Product.find_by(item_id: offer.at_css('Ид').content)
        price = offer.at_css('ЦенаЗаЕдиницу').content
        product.price = price.to_f
        # p product.title + ' price: ' + price
        product.save
      else
        prices_progress.log 'Product ' + offer.at_css('Наименование').content + ' not found'
      end
      prices_progress.increment
    end
  else 
    print "Prices haven't been defined in 'offers.xml'. Create random price for each product?[y/n]: "
    input = STDIN.gets.chomp
    if input == 'y'
      prices_progress = ProgressBar.create(total: Product.all.size, progress_mark: '█', format: "%P%%: |%B| %c of %C %E")
      Product.all.each do |p|
        p.update(price: rand(1..10000))
        prices_progress.increment
      end
    end
  end

  p "End"
end


def add_values_to_values
  p "Populating value attribute"

  values_progress = ProgressBar.create(total: Value.all.size, progress_mark: '█', format: "%P%%: |%B| %c of %C %E")
  Value.all.each do |val|
    title = val.title.split(' ')
    val.update value: (val.title.match(/^\d+(.\d+)?$/)) ? title[0].to_f : nil
    values_progress.increment
  end

  p "End"
end

def create_first_admin_user
  puts "Creating first user with admin priveleges:"
  email = HighLine.ask('email: '){|q| q.case = :down; q.validate = /[a-z][\w\.\-]+@([a-z]+[\w\-]+\.)+[a-z]{2,5}/}
  f = ''
  while f != 'y' do
    password = HighLine.ask('Your password: '){|q| q.echo = '*'}
    c_pass = HighLine.ask('Confirm pass: '){|q| q.echo = '*'}
    if password == c_pass
      User.create!(email: email, password: password, password_confirmation: password, group: 'admin')
      f = 'y'
    else
      puts "Passwords don't match, try again"
    end
  end
  puts "User #{email} successfully created!"
end

main
