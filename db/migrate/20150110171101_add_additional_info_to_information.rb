class AddAdditionalInfoToInformation < ActiveRecord::Migration
  def change
    add_column :information, :director, :string
    add_column :information, :contact, :string
    add_column :information, :shipping_name, :string
    add_column :information, :shipping_address, :string
    add_column :information, :shipping_phone, :string
  end
end
