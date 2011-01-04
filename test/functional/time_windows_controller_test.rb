require 'test_helper'

class TimeWindowsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:time_windows)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create time_window" do
    assert_difference('TimeWindow.count') do
      post :create, :time_window => { }
    end

    assert_redirected_to time_window_path(assigns(:time_window))
  end

  test "should show time_window" do
    get :show, :id => time_windows(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => time_windows(:one).to_param
    assert_response :success
  end

  test "should update time_window" do
    put :update, :id => time_windows(:one).to_param, :time_window => { }
    assert_redirected_to time_window_path(assigns(:time_window))
  end

  test "should destroy time_window" do
    assert_difference('TimeWindow.count', -1) do
      delete :destroy, :id => time_windows(:one).to_param
    end

    assert_redirected_to time_windows_path
  end
end
