module ProductGroupsHelper
  def menu_for_group(group)
    out = ''
    out << '<li'
    out << ' class="parent"' if group.children.presence
    out << '>' + link_to(group.title, group)
    if group.children.presence
      out << '<ul class="child">'
      for child in group.children do
        out << menu_for_group(child)
      end
      out << '</ul>'
    end
    puts out << '</li>'
    out
  end

end
