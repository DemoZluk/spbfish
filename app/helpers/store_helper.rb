module StoreHelper
  def image_thumb_helper
    thumb_path = 'assets/images/thumbnails/'
    if 
  end
end
product = Product.find(166)
group = ProductGroups.find('ksdfkjs')
hash = {group.group_id => {parent: group.parent_id}}
while group = group.parent
  temp = {parent: group.group_id}
  hash.deep_merge!(temp)
end