require 'rails_helper'

RSpec.describe User, type: :model do
  # Association tests
  it { should have_many(:borrowings) }
  it { should have_many(:borrowed_books).through(:borrowings).source(:book) }

  # Validation tests
  it 'is valid with valid attributes' do
    user = create(:user)
    expect(user).to be_valid
  end

  it 'is not valid without an email' do
    user = build(:user, email: nil)
    expect(user).to_not be_valid
  end

  it 'is not valid without a password' do
    user = build(:user, password: nil)
    expect(user).to_not be_valid
  end

  it 'does not allow duplicate emails' do
    create(:user, email: 'user@example.com')
    duplicate_user = build(:user, email: 'user@example.com')
    expect(duplicate_user).to_not be_valid
  end
end
