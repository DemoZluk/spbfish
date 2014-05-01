class AddKeywordsAndDescriptionToProducts < ActiveRecord::Migration
  def change
    add_column :products, :html_keywords, :string
    add_column :products, :html_description, :string
  end
end
