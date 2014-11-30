class ChanageProductPropertyValuesColumnsTypeToInteger < ActiveRecord::Migration
  def change
  	change_column :product_property_values, :product_id, :integer
  	change_column :product_property_values, :property_id, :integer
  	change_column :product_property_values, :value_id, :integer
  end
end
