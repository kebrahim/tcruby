require 'test_helper'

class PicksControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
