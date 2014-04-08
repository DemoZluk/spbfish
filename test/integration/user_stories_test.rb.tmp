#encoding: utf-8
require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  fixtures :products
  test 'buying a product' do
    LineItem.delete_all
    Order.delete_all
    ruby_book = products(:ruby)

    get "/"
    assert_response :success
    assert_template "index"
    xml_http_request :post, '/line_items', product_id: ruby_book.id
    assert_response :success

    cart = Cart.find(session[:cart_id])
    assert_equal 1, cart.line_items.size
    assert_equal ruby_book, cart.line_items[0].product

    get "/orders/new"
    assert_response :success
    assert_template "new"

    order_data = { id: 1,
            name: "Dave Thomas",
         address: "123 The Street",
           email: "dave@example.com",
        pay_type: "Самовывоз",
   shipping_date: Date.tomorrow }
    #puts LineItem.all.to_yaml

    post_via_redirect "/orders", order: order_data
    #puts LineItem.all.to_yaml
    assert_response :success
    orders = Order.all
    assert_equal 1, orders.size
    assert_template "index"

    order = orders.first
    assert_equal 1, order.line_items.size
    line_item = order.line_items[0]
    assert_equal ruby_book, line_item.product
    assert_equal "Dave Thomas", order.name
    assert_equal "123 The Street", order.address
    assert_equal "dave@example.com", order.email
    assert_equal "Самовывоз", order.pay_type
    
    # puts mail = ActionMailer::Base.deliveries.last
    # assert_equal ["dave@example.com"], mail.to
    # assert_equal 'Sam Ruby <depot@example.com>', mail[:from].value
    # assert_equal "Pragmatic Store Order Confirmation", mail.subject

    # puts cart.line_items.to_yaml
    # assert_equal 0, cart.line_items.size
  end
end
