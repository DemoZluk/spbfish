class CreateMenuItems < ActiveRecord::Migration
  def change
    create_table :menu_items do |t|
      t.string :title
      t.string :permalink
      t.integer :parent_id
      t.boolean :published, default: false

      t.timestamps
    end
  end
end
