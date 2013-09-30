class AddPermalinkColumnToProducts < ActiveRecord::Migration
  def change
    add_column :products, :permalink, :string

    Product.all.each do |product|
      product.permalink = product.title.gsub(/\s+/, '_')
      product.save
    end
  end
end
