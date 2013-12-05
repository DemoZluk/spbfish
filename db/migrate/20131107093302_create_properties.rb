class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.string :property_id
      t.string :title
    end
  end
end
