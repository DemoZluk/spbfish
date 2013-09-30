class CopyPriceToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :price, :float

    LineItem.all.each do |item|
      item.price = Product.find(item.product_id).price
      item.save
    end
  end
end
