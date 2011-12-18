require 'test_helper'

class CartsControllerTest < ActionController::TestCase
  test "should get add" do
    get :add
    assert_response :success
  end

  test "should get clear" do
    get :clear
    assert_response :success
  end

end
