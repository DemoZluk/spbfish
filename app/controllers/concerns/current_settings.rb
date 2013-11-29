module CurrentSettings
  extend ActiveSupport::Concern

  included do
  end

  def change_user_prefs
    # Create user preferences in session if undefined
    session[:user] ||= Hash[:prefs, {per_page: 10, order_by: 'title'}].with_indifferent_access unless session && session[:user] && session[:user][:prefs]

    session[:user][:prefs].delete_if{|key, val| val.blank?} if session[:user][:prefs] = user_prefs.presence

    group_filters

    # Update user preferences
    @per_page = session[:user][:prefs][:per_page] ||= 10
    @order_by = session[:user][:prefs][:order_by] ||= 'title'
    @desc = session[:user][:prefs][:descending].presence
    @order_by = @order_by + ' DESC' if @desc
  end

  # Define product list for current group
  # if group is present, else list all products
  def current_products products
    prod = filter_products products
    @products = prod.page(params[:page]).per(@per_page)
    # redirect_to store_path, notice: 'No results' if @products.empty?
  end

  def filter_products products
    set_min_max_price(products)
    min = @min_price
    max = @max_price
    products = products.where{(price >= min) & (price <= max)}

    if producers = params[:producer]
      products = products.where{producer.in producers}
    end
    products
    # if properties = params[:property]
    #   properties.each do |property|
    #     products.where{}
    # end
  end

  def set_min_max_price products
    param_min = params[:minPrice].to_i.abs
    param_max = params[:maxPrice].to_i.abs
    @products_min = products.minimum(:price).floor
    @products_max = products.maximum(:price).ceil
    @min_price = (param_min == 0) ? @products_min : ((param_min < @products_max) ? param_min : @products_max-1)
    @max_price = (param_max == 0) ? @products_max : ((param_max > @min_price) ? param_max : @min_price+1)
    @max_price = @min_price+1 if @max_price <= @min_price
  end

  private

    def user_prefs
      params.slice(:per_page, :order_by, :descending).presence || session[:user][:prefs]
    end

    def group_filters
      filters = params.except(:page, :per_page, :order_by, :descending, :utf8, :commit, :action, :controller, :id).presence || session[:group]
      params.merge! filters.delete_if { |key, value| value == '' } if filters.presence
    end
end