class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :user_id
      t.integer :product_id
      t.integer :value

      t.timestamps
    end

    remove_column :products, :rating, :float
    remove_column :products, :rating_counter, :integer
  end
end
