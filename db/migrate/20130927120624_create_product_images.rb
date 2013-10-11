class CreateProductImages < ActiveRecord::Migration
  def change
    create_table :product_images, primary_key: :item_id do |t|
      t.string :url
      t.string :item_id

      t.timestamps
    end
  end
end
