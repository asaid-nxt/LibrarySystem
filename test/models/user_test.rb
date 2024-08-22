require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user is valid with valid attributes" do
    user = User.new(email: "test@example.com", password: "password")
    assert user.valid?
  end

  test "user is invalid without an email" do
    user = User.new(password: "password")
    assert_not user.valid?, "User is valid without an email"
  end

  test "user is invalid without a password" do
    user = User.new(email: "test@example.com")
    assert_not user.valid?, "User is valid without a password"
  end
end
