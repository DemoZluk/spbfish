class AddRatingToProducts < ActiveRecord::Migration
  def change
    add_column :products, :rating, :decimal, precision: 2, scale: 1
    add_column :products, :rating_counter, :integer
  end
end
