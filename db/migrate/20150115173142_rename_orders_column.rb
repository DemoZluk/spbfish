class RenameOrdersColumn < ActiveRecord::Migration
  def change
    rename_column :orders, :pay_type, :shipping_type
  end
end
