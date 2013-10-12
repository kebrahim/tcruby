require 'test_helper'

class DraftPicksControllerTest < ActionController::TestCase
  setup do
    @draft_pick = draft_picks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:draft_picks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create draft_pick" do
    assert_difference('DraftPick.count') do
      post :create, draft_pick: { league: @draft_pick.league, pick: @draft_pick.pick, round: @draft_pick.round }
    end

    assert_redirected_to draft_pick_path(assigns(:draft_pick))
  end

  test "should show draft_pick" do
    get :show, id: @draft_pick
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @draft_pick
    assert_response :success
  end

  test "should update draft_pick" do
    put :update, id: @draft_pick, draft_pick: { league: @draft_pick.league, pick: @draft_pick.pick, round: @draft_pick.round }
    assert_redirected_to draft_pick_path(assigns(:draft_pick))
  end

  test "should destroy draft_pick" do
    assert_difference('DraftPick.count', -1) do
      delete :destroy, id: @draft_pick
    end

    assert_redirected_to draft_picks_path
  end
end
