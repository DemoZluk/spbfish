module GroupsHelper
  def menu_for_group product_group
    out = ''
    out << '<li'
    out << ' class="parent"' if product_group.children.presence
    out << '>' + link_to(product_group.title, product_group)
    if product_group.children.any?
      out << '<ul class="child">'
      for child in product_group.children do
        out << menu_for_group(child)
      end
      out << '</ul>'
    end
    out << '</li>'
  end

end
