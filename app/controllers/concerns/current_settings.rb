module CurrentSettings
  extend ActiveSupport::Concern

  included do
  end

  def change_user_prefs
    # Create user preferences in session if undefined
    session[:user] ||= Hash[:prefs, {per_page: 10, order_by: 'title'}].with_indifferent_access unless session && session[:user] && session[:user][:prefs]

    session[:user][:prefs].delete_if{|key, val| val.blank?} if session[:user][:prefs] = user_prefs.presence

    # Update user preferences
    @per_page = session[:user][:prefs][:per_page] ||= 10
    @order_by = 'products.' + session[:user][:prefs][:order_by] ||= 'title'
    @desc = session[:user][:prefs][:descending].presence
    @order_by += ' DESC' if @desc
  end

  # Define product list for current group
  # if group is present, else list all products
  def current_list_of products
    prod = filter products
    @products = prod.page(params[:page]).per(@per_page)
    # redirect_to store_path, notice: 'No results' if @products.empty?
  end

  def filter products

    set_min_max_price_for products

    products = products.where(price: @min_price..@max_price).includes{values}

    producers = params[:producer]
    products = products.where{producer >> producers} if producers

    query = []

    if rng = params[:r]
      rng.each do |k,v|
        if v.reject(&:empty?).any?
          min = v[0].to_f
          max = v[1].presence || Value.where{property_id == Property.find(k).property_id}.maximum(:value)
          query << "(`values`.`value` >= #{min} AND `values`.`value` <= #{max} AND `product_property_values`.`property_id` = #{k})"
        end
      end
    end

    if flt = params[:p]
      query << "(`product_property_values`.`value_id` IN (#{flt.join(', ')}))"
    end

    if rng || flt
      c = 0
      c += Value.uniq.where{id >> flt}.group_by{|value| value.property_id}.count if flt
      c += params[:r].keep_if{|k,v| v.reject(&:empty?).any?}.count if rng
      
      products = products.where(query.join(' OR ')).group{id}.having{count(product_property_values.property_id) >= c}
    end

    # vals << params[:p].map(&:to_s) if params[:p] && params[:p].any?

    # unless vals.empty?
    #   vv = Value.joins{product_property_values}.where{id >> vals.flatten}.pluck('product_property_values.product_id')
    #   products = products.where{id >> vv}
    # end

    products
  end

  def set_min_max_price_for products
    param_min = params[:minPrice].to_i.abs
    param_max = params[:maxPrice].to_i.abs
    @products_min = products.minimum(:price).to_i.try :floor
    @products_max = products.maximum(:price).to_i.try :ceil
    @min_price = (param_min == 0) ? @products_min : ((param_min < @products_max) ? param_min : @products_max-1)
    @max_price = (param_max == 0) ? @products_max : ((param_max > @min_price) ? param_max : @min_price+1)
    @max_price = @min_price+1 if @max_price <= @min_price
  end

  private

    def user_prefs
      params.slice(:per_page, :order_by, :descending).presence || session[:user][:prefs]
    end
end