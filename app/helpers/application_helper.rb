#encoding: utf-8
module ApplicationHelper
  def hidden_div_if(condition, attributes = {}, &block)
    if condition
      attributes['style'] = 'display:none;'
    end
    content_tag(:div, attributes, &block)
  end

  def page_title
    @title = (@page_title || t(params[:controller])[params[:action].to_sym][:title]) + ' - ' + @app_name
    rescue
      @title = @app_name
  end

  def display_product_image(item_id)
    if item = ProductImage.where(item_id: item_id).presence
      item.map {|i| i.image_url}
    end
  end

  def selection_label(current)
    if current.to_i == 0
      label = I18n.t('selection_labels.'+current)
    else
      label = current
    end
  end
end
