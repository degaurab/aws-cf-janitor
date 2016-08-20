require 'test_helper'

class AwsDataControllerTest < ActionController::TestCase
  setup do
    @aws_datum = aws_data(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:aws_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create aws_datum" do
    assert_difference('AwsDatum.count') do
      post :create, aws_datum: { aws_access_key: @aws_datum.aws_access_key, aws_secret_key: @aws_datum.aws_secret_key, manifest_template: @aws_datum.manifest_template }
    end

    assert_redirected_to aws_datum_path(assigns(:aws_datum))
  end

  test "should show aws_datum" do
    get :show, id: @aws_datum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @aws_datum
    assert_response :success
  end

  test "should update aws_datum" do
    patch :update, id: @aws_datum, aws_datum: { aws_access_key: @aws_datum.aws_access_key, aws_secret_key: @aws_datum.aws_secret_key, manifest_template: @aws_datum.manifest_template }
    assert_redirected_to aws_datum_path(assigns(:aws_datum))
  end

  test "should destroy aws_datum" do
    assert_difference('AwsDatum.count', -1) do
      delete :destroy, id: @aws_datum
    end

    assert_redirected_to aws_data_path
  end
end
