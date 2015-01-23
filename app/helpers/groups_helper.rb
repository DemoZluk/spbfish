module GroupsHelper
  def menu_for_group product_group
    if product_group.all_products.accessible_by(current_ability).any?
      path = group_path(id: product_group.permalink)
      children = product_group.children
      cls = ''
      cls << 'parent' if children.any?
      cls << ' current' if current_page?(path)
      content_tag :li, class: cls do
        string = ": #{children.map { |c| c.title }.join(', ')}" if children.any?
        link_to(product_group.title, path, title: (product_group.title + string.to_s)) +
        if children.any?
          ul = content_tag :ul, class: 'child' do
            children.collect do |child|
              menu_for_group(child)
            end.join.html_safe
          end
        end
      end
    end
  end
end
