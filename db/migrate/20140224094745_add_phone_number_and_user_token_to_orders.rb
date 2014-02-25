class AddPhoneNumberAndUserTokenToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :phone_number, :string
    add_column :orders, :token, :string
    add_column :orders, :comment, :string
  end
end
