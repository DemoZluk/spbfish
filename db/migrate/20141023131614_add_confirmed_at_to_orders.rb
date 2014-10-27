class AddConfirmedAtToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :confirmed_at, :datetime
  end
end
