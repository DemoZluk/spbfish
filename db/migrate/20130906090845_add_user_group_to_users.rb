class AddUserGroupToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_group, :string, default: 'user'
  end
end
