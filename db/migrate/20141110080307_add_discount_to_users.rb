class AddDiscountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :discount, :integer, default: 0

    User.all.update_all(discount: 0)
  end
end
