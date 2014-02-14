class ChangePricesColumn < ActiveRecord::Migration
  def change
    change_column :products, :price, :float, null: false, default: 0
  end
end
