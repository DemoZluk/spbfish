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
      item.map {|i| i.url}
    end
  end

  def selection_label(current)
    if current.to_i == 0
      label = I18n.t('selection_labels.'+current.to_s)
    else
      label = current
    end
  end

  def min(obj, attribute)
    number_with_delimiter(obj.sort_by {|p| p[attribute]}.first[attribute].floor)
  end

  def max(obj, attribute)
    number_with_delimiter(obj.sort_by {|p| p[attribute]}.reverse!.first[attribute].ceil)
  end
end
