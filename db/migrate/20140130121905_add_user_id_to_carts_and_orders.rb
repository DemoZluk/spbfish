class AddUserIdToCartsAndOrders < ActiveRecord::Migration
  def change
    add_column :carts, :user_id, :int
    add_column :orders, :user_id, :int
  end
end
