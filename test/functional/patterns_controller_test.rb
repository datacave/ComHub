require 'test_helper'

class PatternsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:patterns)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pattern" do
    assert_difference('Pattern.count') do
      post :create, :pattern => { }
    end

    assert_redirected_to pattern_path(assigns(:pattern))
  end

  test "should show pattern" do
    get :show, :id => patterns(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => patterns(:one).to_param
    assert_response :success
  end

  test "should update pattern" do
    put :update, :id => patterns(:one).to_param, :pattern => { }
    assert_redirected_to pattern_path(assigns(:pattern))
  end

  test "should destroy pattern" do
    assert_difference('Pattern.count', -1) do
      delete :destroy, :id => patterns(:one).to_param
    end

    assert_redirected_to patterns_path
  end
end
