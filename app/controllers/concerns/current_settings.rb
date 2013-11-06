module CurrentSettings
  extend ActiveSupport::Concern

  included do
  end

  # Define product list for current group
  # if group is present, else list all products
  def current_products
    @group = Group.find_by_permalink(params[:id])

    if @group
      products = children?(@group).flatten.sort_by(&:"#{@order_by}")
    else
      products = Product.all.flatten.sort_by(&:"#{@order_by}")
    end
    products.reverse! if @desc
    @products = Kaminari.paginate_array(products).page(params[:page]).per(@per_page)
  end

  # If group has any children, recursively
  # get all produts from all descendants
  def children?(group)
    products = []
    products += group.products
    if group.children.any?
      for child in group.children do
        products += children?(child)
      end
    end
    products
  end

  def change_user_prefs
    # Create user preferences if undefined
    unless session && session[:user] && session[:user][:prefs]
      session[:user] ||= Hash[:prefs, {}]
    end

    prefs = params.except('utf8', 'action', 'controller', 'id')
    if prefs.presence
      session[:user][:prefs].deep_merge! prefs
      session[:user][:prefs]['descending'] = nil unless prefs['descending']
    end

    # Update user preferences
    @per_page = session[:user][:prefs]['per_page'] ||= 10
    @order_by = session[:user][:prefs]['order_by'] ||= 'title'
    @desc = session[:user][:prefs]['descending'] ||= nil

    current_products
  end
end