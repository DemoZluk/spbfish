class CreateInformation < ActiveRecord::Migration
  def change
    create_table :information do |t|
      t.integer :user_id
      t.string :phone_number
      t.string :name
      t.string :address

      t.timestamps
    end
  end
end
