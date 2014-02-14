class AddValueToValues < ActiveRecord::Migration
  def change
    add_column :values, :value, :float
  end
end
