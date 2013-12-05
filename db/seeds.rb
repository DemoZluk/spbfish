#encoding:utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

file = File.read('xml/import.xml')
doc = Nokogiri::XML(file)

doc.xpath('//Группы/descendant::Группа').each do |g|
  parent = g.xpath('ancestor::Группа').last
  group_id = g.at_css('>Ид').content
  if parent
    parent_id = parent.at_css('>Ид').content
  else
    parent_id = ''
  end
  title = g.at_css('>Наименование').content
  permalink = title.mb_chars.parameterize('_') #.gsub(/[^-\wа-яА-ЯёЁ]+/i, ' ').squish.gsub(/\s+/, '_')
  Group.create(
    id: group_id,
    title: title,
    parent_id: parent_id,
    permalink: permalink
  )
end

p 'Created groups'

doc.css('Товар').each do |product|
  product_title = product.at_css('>Наименование').content
  permalink = product_title.mb_chars.parameterize('_') #.gsub(/[^-\wа-яА-ЯёЁ]+/i, ' ').squish.gsub(/\s+/, '_')
  unless Product.find_by_permalink(permalink)

    Product.create!(
      item: product.at_css('>Артикул').content,
      title: product_title,
      long_name: product.at_xpath("ЗначенияРеквизитов/ЗначениеРеквизита[Наименование='Полное наименование']/Значение").content,
      description: product.at_css('>Описание').inner_html,
      price: rand(100..5000),
      producer: product.at_css('>Изготовитель>Наименование').content,
      item_id: product.at_css('>Ид').content,
      unit: product.at_css('>БазоваяЕдиница').content,
      group_id: product.at_css('>Группы>Ид').content,
      permalink: permalink,
      rating: 0
    )
  end

  product.css('ЗначенияСвойства').each do |p|
    ProductPropertyValue.create(
      item_id:product.at_css('>Ид').content,
      property_id: p.at_css('Ид').content,
      value_id: p.at_css('Значение').content
    )
  end

  product.css('Картинка').each do |img|
    Image.create(
      url: img.content,
      item_id: product.at_css('>Ид').content
    )
  end
end

p 'Created Products and Values'

doc.css('Свойство').each do |p|
  id = p.at_css('Ид').content
  title = p.at_css('Наименование').content
  Property.create(
    property_id: id,
    title: title
  )

  p.css('ВариантыЗначений>Справочник').each do |v|
    PropertyValue.create(
      value_id: v.at_css('ИдЗначения').content,
      title: v.at_css('Значение').content,
      property_id: id
    )
  end
end

p 'Created Properties'