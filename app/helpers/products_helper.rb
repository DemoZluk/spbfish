#encoding: utf-8
module ProductsHelper
  def link_to_product product, html_options = {}, query = nil
    link_to highlight(product.title, query), show_product_path(gid: product.group.permalink, id: product.permalink, q: params[:q]), html_options
  end
end
