class AddAliasToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :alias, :string
  end
end
