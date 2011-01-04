require 'test_helper'

class AcknowledgmentsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:acknowledgments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create acknowledgment" do
    assert_difference('Acknowledgment.count') do
      post :create, :acknowledgment => { :from => 'david.krider@thedatacave.com',
				:body => 'Abc' }
    end

    assert_redirected_to acknowledgment_path(assigns(:acknowledgment))
  end

  test "should show acknowledgment" do
    get :show, :id => acknowledgments(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => acknowledgments(:one).to_param
    assert_response :success
  end

  test "should update acknowledgment" do
    put :update, :id => acknowledgments(:one).to_param, :acknowledgment => { }
    assert_redirected_to acknowledgment_path(assigns(:acknowledgment))
  end

  test "should destroy acknowledgment" do
    assert_difference('Acknowledgment.count', -1) do
      delete :destroy, :id => acknowledgments(:one).to_param
    end

    assert_redirected_to acknowledgments_path
  end
end
