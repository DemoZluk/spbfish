require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  setup do
    sign_in users :one
    @ordr = orders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:orders)
  end

  test "should get new" do
    item = LineItem.new
    item.build_cart
    item.product = products(:ruby)
    item.save!
    session[:cart_id] = item.cart.id

    get :new
    assert_response :success
  end

  test "should create order" do
    assert_difference('Order.count') do
      post :create, order: @ordr.attributes.merge('shipping_date' => DateTime.tomorrow)
    end
  end

  test "should fail to create order" do
    assert_no_difference('Order.count') do
      post :create, order: { address: @ordr.address, email: @ordr.email, name: @ordr.name, pay_type: @ordr.pay_type, shipping_date: DateTime.current-1 }
    end
  end

  test "should show order" do
    get :show, id: @ordr
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ordr.id, token: @ordr.token
    assert_redirected_to store_url
  end

  test "should update order" do
    patch :update, id: @ordr, order: { address: @ordr.address, email: @ordr.email, name: @ordr.name, pay_type: @ordr.pay_type }
  end
end
