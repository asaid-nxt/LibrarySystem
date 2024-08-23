require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = User.create!(email: "test11@example.com", password: "123456")
  end

  # Test case for user sign up with valid credentials
  test "should sign up user with valid credentials" do
    post user_registration_path, params: { user: { email: "newuser@example.com", password: "newpassword", password_confirmation: "newpassword" } }, as: :json

    assert_response :created
    json_response = JSON.parse(response.body)

    assert_equal "Signed up successfully.", json_response['message'] # Update the success message here
    assert_equal "newuser@example.com", json_response['user']['email']
  end

  # Test case for user sign up with invalid credentials
  test "should not sign up user with invalid credentials" do
    post user_registration_path, params: { user: { email: "invalidemail", password: "short", password_confirmation: "different" } }, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)

    # Check that the error message returned matches the validation errors
    assert_match /Email is invalid/, json_response['error']
    assert_match /Password confirmation doesn't match Password/, json_response['error']
    assert_match /Password is too short/, json_response['error']
  end

  # Test case for sign in user with valid credentials
  test "should sign in user with valid credentials" do
    post user_session_path, params: { user: { email: @user.email, password: '123456' } }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)

    assert_equal "Logged in successfully.", json_response['message']
    assert_equal @user.email, json_response['user']['email']
  end

  # Test case for sign in user with invalid credentials
  test "should fail with invalid credentials" do
    post user_session_path, params: { user: { email: @user.email, password: 'wrongpassword' } }, as: :json

    assert_response :unauthorized
    json_response = JSON.parse(response.body)

    assert_equal "Invalid email or password", json_response['error']
  end

  # Test case for log out user
  test "should log out user" do
    sign_in @user
    delete destroy_user_session_path, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)

    assert_equal "Logged out successfully.", json_response['message']
  end
end
