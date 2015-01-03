require 'test_helper'

class S3InfosControllerTest < ActionController::TestCase
  setup do
    @s3_info = s3_infos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:s3_infos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create s3_info" do
    assert_difference('S3Info.count') do
      post :create, s3_info: { access_key: @s3_info.access_key, bucket: @s3_info.bucket, region: @s3_info.region, secret_key: @s3_info.secret_key }
    end

    assert_redirected_to s3_info_path(assigns(:s3_info))
  end

  test "should show s3_info" do
    get :show, id: @s3_info
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @s3_info
    assert_response :success
  end

  test "should update s3_info" do
    patch :update, id: @s3_info, s3_info: { access_key: @s3_info.access_key, bucket: @s3_info.bucket, region: @s3_info.region, secret_key: @s3_info.secret_key }
    assert_redirected_to s3_info_path(assigns(:s3_info))
  end

  test "should destroy s3_info" do
    assert_difference('S3Info.count', -1) do
      delete :destroy, id: @s3_info
    end

    assert_redirected_to s3_infos_path
  end
end
