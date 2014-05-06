desc "Update products table"
task :update_products_table => :environment do
  Product.update_products_table
end