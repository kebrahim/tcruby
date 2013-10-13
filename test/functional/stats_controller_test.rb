require 'test_helper'

class StatsControllerTest < ActionController::TestCase
  test "should get scoreboard" do
    get :scoreboard
    assert_response :success
  end

end
