require 'test_helper'

class KeywordsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:keywords)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create keyword" do
    assert_difference('Keyword.count') do
      post :create, :keyword => { :designation => 'Nothing' }
    end

    assert_redirected_to keyword_path(assigns(:keyword))
  end

  test "should show keyword" do
    get :show, :id => keywords(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => keywords(:one).to_param
    assert_response :success
  end

  test "should update keyword" do
    put :update, :id => keywords(:one).to_param, :keyword => { }
    assert_redirected_to keyword_path(assigns(:keyword))
  end

  test "should destroy keyword" do
    assert_difference('Keyword.count', -1) do
      delete :destroy, :id => keywords(:one).to_param
    end

    assert_redirected_to keywords_path
  end
end
