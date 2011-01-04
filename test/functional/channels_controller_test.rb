require 'test_helper'

class ChannelsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:channels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create channel" do
    assert_difference('Channel.count') do
      post :create, :channel => { :mechanism => Mechanism.find_by_designation("smtp"),
        :address => 'first.last@asdf.com' }
    end

    assert_redirected_to channel_path(assigns(:channel))
  end

  test "should show channel" do
    get :show, :id => channels(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => channels(:one).to_param
    assert_response :success
  end

  test "should update channel" do
    put :update, :id => channels(:one).to_param, :channel => { }
    assert_redirected_to channel_path(assigns(:channel))
  end

  test "should destroy channel" do
    assert_difference('Channel.count', -1) do
      delete :destroy, :id => channels(:one).to_param
    end

    assert_redirected_to channels_path
  end
end
