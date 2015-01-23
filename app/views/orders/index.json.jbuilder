json.array!(@orders) do |order|
  json.extract! order, :name, :address, :email, :shipping_type
  json.url order_url(order, format: :json)
end
