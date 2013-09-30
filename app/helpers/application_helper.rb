#encoding: utf-8
module ApplicationHelper
  def hidden_div_if(condition, attributes = {}, &block)
    if condition
      attributes['style'] = 'display:none;'
    end
    content_tag(:div, attributes, &block)
  end

  def page_title(controller_name, action_name)
    @title = (@page_title || t(controller_name)[action_name.to_sym][:title]) + ' - ' + @app_name
    rescue
      @title = @app_name
  end

  def display_product_image(item_id)
    if item = ProductImage.where(item_id: item_id).presence
      item.map {|i| i.image_url}
    end
  end
end
