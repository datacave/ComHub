require 'test_helper'

class MechanismsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mechanisms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mechanism" do
    assert_difference('Mechanism.count') do
      post :create, :mechanism => { }
    end

    assert_redirected_to mechanism_path(assigns(:mechanism))
  end

  test "should show mechanism" do
    get :show, :id => mechanisms(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => mechanisms(:one).to_param
    assert_response :success
  end

  test "should update mechanism" do
    put :update, :id => mechanisms(:one).to_param, :mechanism => { }
    assert_redirected_to mechanism_path(assigns(:mechanism))
  end

  test "should destroy mechanism" do
    assert_difference('Mechanism.count', -1) do
      delete :destroy, :id => mechanisms(:one).to_param
    end

    assert_redirected_to mechanisms_path
  end
end
