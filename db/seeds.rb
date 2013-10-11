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
doc.css('Товар').each do |product|

  product_title = product.at_css('>Наименование').content
  permalink = product_title.gsub(/[^-\wа-яё]+/i, ' ').squish.gsub(/\s+/, '_')

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
    permalink: permalink
  )
  product.css('Картинка').each do |img|
    ProductImage.create(
      url: img.content,
      item_id: product.at_css('>Ид').content
    )
  end
end

doc.xpath('//Группы/descendant::Группа').each do |g|
  parent = g.xpath('ancestor::Группа').last
  group_id = g.at_css('>Ид').content
  if parent
    parent_id = parent.at_css('>Ид').content
  else
    parent_id = ''
  end
  ProductGroups.create(
    group_id: group_id,
    title: g.at_css('>Наименование').content,
    parent_id: parent_id
  )
end