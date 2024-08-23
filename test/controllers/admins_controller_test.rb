require "test_helper"

class AdminsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @admin = Admin.create!(email: "admin11@example.com", password: "123456")
  end

  # Test case for admin sign up with valid credentials
  test "should sign up admin with valid credentials" do
    post admin_registration_path, params: { admin: { email: "newadmin@example.com", password: "newpassword", password_confirmation: "newpassword" } }, as: :json

    assert_response :created
    json_response = JSON.parse(response.body)

    assert_equal "Signed up successfully.", json_response['message']
    assert_equal "newadmin@example.com", json_response['admin']['email']
  end

  # Test case for admin sign up with invalid credentials
  test "should not sign up admin with invalid credentials" do
    post admin_registration_path, params: { admin: { email: "invalidemail", password: "short", password_confirmation: "different" } }, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)

    # Check that the error message returned matches the validation errors
    assert_match /Email is invalid/, json_response['error']
    assert_match /Password confirmation doesn't match Password/, json_response['error']
    assert_match /Password is too short/, json_response['error']
  end

  # Test case for sign in admin with valid credentials
  test "should sign in admin with valid credentials" do
    post admin_session_path, params: { admin: { email: @admin.email, password: '123456' } }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)

    assert_equal "Logged in successfully.", json_response['message']
    assert_equal @admin.email, json_response['admin']['email']
  end

  # Test case for sign in admin with invalid credentials
  test "should fail with invalid credentials" do
    post admin_session_path, params: { admin: { email: @admin.email, password: 'wrongpassword' } }, as: :json

    assert_response :unauthorized
    json_response = JSON.parse(response.body)

    assert_equal "Invalid email or password", json_response['error']
  end

  # Test case for log out admin
  test "should log out admin" do
    sign_in @admin
    delete destroy_admin_session_path, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)

    assert_equal "Logged out successfully.", json_response['message']
  end
end
