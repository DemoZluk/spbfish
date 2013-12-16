class CreateValues < ActiveRecord::Migration
  def change
    create_table :values do |t|
      t.string :title
      t.string :value_id
      t.string :property_id
    end
  end
end
