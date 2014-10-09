module StoreHelper
  def list_item_for p, item, cnt, options = {}
    title = options[:title] || item.try(:title) || item
    checked = options[:dsb] || (params[p].try(:index, ((p == 'producer') ? item : item.id.to_s)))
    id = item.try(:id) || item
    li = content_tag :li do
      check_box_tag("#{p}[]", id, checked, {id: "#{id}_#{title.parameterize}", disabled: options[:dsb]}) + 
      label_tag("#{id}_#{title.parameterize}", title) + 
      content_tag(:span, " (#{cnt})", class: 'count')
    end
  end

  def numeric? array
    array.map{|v| v.value.to_f}.compact
  end
end