class RepopulateProductsTable < ActiveRecord::Migration
  def change
    drop_table :products
    create_table :products do |t|
      t.string :item
      t.string :title
      t.string :long_name
      t.text :description
      t.decimal :price
      t.string :producer
      t.string :item_id
      t.string :unit
      t.string :group_id
      t.decimal :rating, precision: 2, scale: 1
      t.integer :rating_counter
      t.string :permalink

      t.timestamps
    end
  end
end
