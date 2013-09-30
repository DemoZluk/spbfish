class CreateProductGroups < ActiveRecord::Migration
  def change
    create_table :product_groups do |t|
      t.string :group_id
      t.string :title
      t.string :parent_id

      t.timestamps
    end
  end
end
