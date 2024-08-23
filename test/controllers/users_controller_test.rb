require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = User.create!(email: "test11@example.com", password: "123456")
  end

  test "should sign in user with valid credentials" do
    post user_session_path, params: { user: { email: @user.email, password: '123456' } }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)

    assert_equal "Logged in successfully.", json_response['message']
    assert_equal @user.email, json_response['user']['email']
  end

  test "should fail with invalid credentials" do
    post user_session_path, params: { user: { email: @user.email, password: 'wrongpassword' } }, as: :json

    assert_response :unauthorized
    json_response = JSON.parse(response.body)

    assert_equal "Invalid email or password", json_response['error']
  end

  test "should log out user" do
    sign_in @user
    delete destroy_user_session_path, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)

    assert_equal "Logged out successfully.", json_response['message']
  end


end
