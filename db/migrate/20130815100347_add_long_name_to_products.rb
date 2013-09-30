class AddLongNameToProducts < ActiveRecord::Migration
  def change
    add_column :products, :long_name, :string

    Product.all.each do |product|
    	product.long_name = ActionController::Base.helpers.truncate(product.description, length: 100, separator: '.', omission: '.')
    	product.save
    end
  end
end
