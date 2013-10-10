class CreateProductGroups < ActiveRecord::Migration
  def change
    create_table :product_groups, primary_key: :group_id do |t|
      t.string :group_id
      t.string :title
      t.string :parent_id

      t.timestamps
    end
  end
end
