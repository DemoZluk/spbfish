class AddDifferentSizesToImages < ActiveRecord::Migration
  def change
    add_column :images, :original_url, :string
    add_column :images, :medium_url, :string
    add_column :images, :thumbnail_url, :string
  end
end
