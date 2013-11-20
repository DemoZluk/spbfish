class CreatePropertyValues < ActiveRecord::Migration
  def change
    create_table :property_values, id: false, primary_key: :id do |t|
      t.string :title
      t.string :id
      t.string :property_id
    end
  end
end
