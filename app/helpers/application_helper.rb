module ApplicationHelper

  def cache_if condition, name = {}, &block
    if condition
      cache name, &block
    else
      yield
    end
  end

  def values_of prop
    if @group
      prods = @group.all_products.with_price.joins{properties}.where{properties.id == prop.id}.pluck(:id).uniq
      prop.values.joins{products}.where{products.id >> prods}.group{id}.uniq.order{count(products.id).desc}
      # prop_id = prop.id
      # product_ids = @group.products.pluck(:id).uniq
      # value_ids = ProductPropertyValue.where{(property_id == prop_id) & (product_id >> product_ids)}.uniq.pluck(:value_id)
      # Value.where{id >> value_ids}.order_by_products_count#.joins{products}.uniq.group{id}#.order{count(products.id).desc}
    else
      []
    end
  end

  def bootstrap_alerts
    string = ''
    if (messages = flash.to_hash.slice(:error, :warning, :notice, :success)).any?
      messages.each do |key, value|
        string << content_tag(:div, (content_tag(:button, "×", class: 'close', type: 'button', data: {dismiss: 'alert'}, 'aria-hidden' => 'true') + value), class: ('alert alert-dismissable  alert-' + key.to_s))
      end
      string.html_safe
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
    title = (@page_title || t(params[:controller])[params[:action].to_sym][:title]) + ' – ' + default rescue default
  end

  def eql item, current
    t('selection_labels.' + item.to_s) == t('selection_labels.' + current.to_s)
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

  def hidden_div_if(condition, attributes = {}, &block)
    if condition
      attributes['style'] = 'display:none;'
    end
    content_tag(:div, attributes, &block)
  end
end
