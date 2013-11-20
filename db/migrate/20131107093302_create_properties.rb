class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties, id: false, primary_key: :id do |t|
      t.string :id
      t.string :title
    end
  end
end
