#encoding: utf-8
module ProductsHelper
  def product_helper
    file = File.read('tmp/import.xml')
    xml_doc = Nokogiri::XML(file)
    products = xml_doc.css('Товар').map do |product|
      prod_name = product.at_css('Наименование').text.gsub(/\s+/, '_')
      product[prod_name] = product.>('*').map do |att|
        att['val'] = att.text
      end
      product
    end
    # %p= product #unless node.>('*').count > 1
    # %tr 
    #   %td
    #     = product.at_css('>Наименование').content
    #   %td
    #     %table{border: 1}
    #       %tr
    #         - product.children.each do |att|
    #           - unless att.name == 'text'
    #             %tr 
    #               %td= att.name
    #               %td= att.content
    #               %td= product.at_css('>Артикул').content
    #               %td= product.at_css('>Наименование').content
    #               %td= product.at_css('>Изготовитель>Наименование').content
    #               %td= product.at_css('>Описание').content
  end
end
