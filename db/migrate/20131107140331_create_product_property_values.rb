class CreateProductPropertyValues < ActiveRecord::Migration
  def change
    create_table :product_property_values do |t|
      t.string :item_id
      t.string :property_id
      t.string :value_id
    end
  end
end
