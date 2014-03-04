desc "Destroy abandoned carts, that are older than 1 day, dayly"
task :destroy_abandoned_carts => :environment do
  Cart.destroy_abandoned_carts(1.day)
end