module GroupsHelper
  def menu_for_group product_group
    path = group_path(pid: product_group.parent.try(:permalink), id: product_group.permalink)
    content_tag :li, class: "#{product_group.children.any? ? 'parent' : nil} #{ current_page?(path) ? 'current' : nil}" do
      link_to(product_group.title, path) +
      if product_group.children.any?
        ul = content_tag :ul, class: 'child' do
          product_group.children.collect do |child|
            menu_for_group(child)
          end.join.html_safe
        end
      end
    end
  end
end
