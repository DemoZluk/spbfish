desc "Update products table"
task :update_products_table => :environment do
  Product.update_products_table
end

desc "Generate images for every product according to db file"
task :generate_images => :environment do
  Product.generate_images
end