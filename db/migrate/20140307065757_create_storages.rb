class CreateStorages < ActiveRecord::Migration
  def change
    create_table :storages do |t|
      t.integer :product_id
      t.float :amount
      t.string :unit

      t.timestamps
    end

    if Product.any?
      Product.all.each do |p|
        Storage.create(product_id: p.id, unit: p.unit)
      end
    end

    remove_column :products, :unit
  end
end
