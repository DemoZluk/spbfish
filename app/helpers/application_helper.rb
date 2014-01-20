module ApplicationHelper

  def values_of property
    if @group
      prop_id = property.id
      product_ids = @group.products.pluck(:id)
      value_ids = ProductPropertyValue.where{(property_id == prop_id) & (product_id >> product_ids)}.pluck(:value_id)
      Value.where{id >> value_ids}.order(:title)
    end
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
    @title = (@page_title || t(params[:controller])[params[:action].to_sym][:title]) + ' - ' + @app_name rescue @app_name
  end

  def display_product_image(item_id)
    if item = ProductImage.where(item_id: item_id).presence
      item.map {|i| i.url}
    end
  end

  def selection_label(current)
    if current.to_i == 0
      label = I18n.t('selection_labels.'+current.match(/\w+/).to_s)
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
