class AddIndexToGroups < ActiveRecord::Migration
  def change
    add_index(:groups, :id)
  end
end
