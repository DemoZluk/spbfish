module GroupsHelper
  def menu_for_group product_group
    path = group_path(pid: product_group.parent.try(:permalink), id: product_group.permalink)
    children = product_group.children
    content_tag :li, class: "#{children.any? ? 'parent' : nil} #{ current_page?(path) ? 'current' : nil}" do
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
