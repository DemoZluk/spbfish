require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  setup do
    @input_attributes = {
      name: 'Joe',
      password: 'pass',
      password_confirmation: 'pass'
    }

    @user = users(:one)
    sign_in users :one
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end
end
