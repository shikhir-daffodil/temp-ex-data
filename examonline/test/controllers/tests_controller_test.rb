require 'test_helper'

class TestsControllerTest < ActionController::TestCase
  test "should get instructions" do
    get :instructions
    assert_response :success
  end

  test "should get test_paper" do
    get :test_paper
    assert_response :success
  end

  test "should get result" do
    get :result
    assert_response :success
  end

end
