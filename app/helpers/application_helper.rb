module ApplicationHelper

  def cache_if condition, name = {}, &block
    if condition
      cache name, &block
    else
      yield
    end
  end

  def link_to_product product, html_options = {}, query = nil
    link_to highlight(product.title, query), product_path(pgid: product.group.permalink, gid: product.group.parent.permalink, id: product.permalink, q: params[:q]), html_options
  end

  def values_of prop

    # !!! Optimize later

    if @group
      prods = @group.products.with_price
      Value.joins{products}.merge(prods).where{property_id == prop.id}.group{title}
      # prop_id = property.id
      # product_ids = @group.products.pluck(:id).uniq
      # value_ids = ProductPropertyValue.where{(property_id == prop_id) & (product_id >> product_ids)}.uniq.pluck(:value_id)
      # Value.where{id >> value_ids}.order_by_products_count#.joins{products}.uniq.group{id}#.order{count(products.id).desc}
    end
  end

  def parent_layout(layout)
    content_for :layout, self.output_buffer
    self.output_buffer = render(:file => "layouts/#{layout}")
  end

  def resource_name
    :user
  end
 
  def resource
    @resource ||= User.new
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def page_title
    default = t('default_title')
    title = (@page_title || t(params[:controller])[params[:action].to_sym][:title]) + ' - ' + default rescue default
  end

  def display_product_image(item_id)
    if item = ProductImage.where(item_id: item_id).presence
      item.map {|i| i.url}
    end
  end

  def eql item, current
    item.to_s.match(/[.\w]+/).to_s == current.to_s.match(/[.\w]+/).to_s.sub('products.', '')
  end

  def selection_label(current)
    if current && (current.to_i == 0)
      label = I18n.t('selection_labels.' + current.match(/[.\w]+/).to_s.sub('products.', ''))
    else
      label = current
    end
  end

  def min(obj, attribute)
    obj.minimum(attribute).floor
  end

  def max(obj, attribute)
    obj.maximum(attribute).ceil
  end

  def test &block
    yield
  end

  def menu_item(condition, name, options = nil, html_options = {})
    if condition
      c = 'btn-gray'
      c << ' current-page' if options == request.path
      options == request.path
      options
      if options.present?
        link_to(name, options, html_options.merge(class: c))
      else
        content_tag(:span, name, html_options.merge(class: c))
      end
    end
  end

  def hidden_div_if(condition, attributes = {}, &block)
    if condition
      attributes['style'] = 'display:none;'
    end
    content_tag(:div, attributes, &block)
  end
end
