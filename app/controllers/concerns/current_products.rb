module CurrentProducts
  extend ActiveSupport::Concern

  # Define product list
  def current_list_of products
    @products = filter(products.accessible_by(current_ability)).page(params[:page]).per(@per_page)
    # redirect_to store_path, notice: 'No results' if @products.empty?
  end

  def filter products
    set_min_max_price_for products

    products = products.where(price: @min_price..@max_price).includes{ratings}

    products = products.includes{values}.references(:values) unless controller_name == 'store'

    producers = params[:producer]
    products = products.where{producer >> producers} if producers

    unless action_name == 'search'
      query = []

      if rng = params[:r]
        rng.each do |k,v|
          if v.reject{ |k1, v1| v1.empty? }.any?
            min = v['min'].to_f
            max = v['max'].presence || Value.where{property_id == Property.find(k).property_id}.maximum(:value)
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
        c += params[:r].keep_if{|k,v| v.reject{ |k1, v1| v1.empty? }.any?}.count if rng

        products = products.where(query.join(' OR ').gsub(/'/, '"')).group{id}.having{count(product_property_values.property_id) >= c}
      end
    end
    products
  end

  def set_min_max_price_for products
    param_min = params[:minPrice].to_i.abs
    param_max = params[:maxPrice].to_i.abs
    @min_price = (param_min == 0) ? products.min_price : ((param_min < products.max_price) ? param_min : products.max_price-1)
    @max_price = (param_max == 0) ? products.max_price : ((param_max > @min_price) ? param_max : @min_price+1)
    @max_price = @min_price+1 if @max_price <= @min_price
  end
end