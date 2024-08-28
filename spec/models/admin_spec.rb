# spec/models/admin_spec.rb
require 'rails_helper'

RSpec.describe Admin, type: :model do
  let(:admin) { build(:admin) }

  it 'is valid with valid attributes' do
    expect(admin).to be_valid
  end

  it 'is not valid without an email' do
    admin.email = nil
    expect(admin).to_not be_valid
  end

  it 'is not valid without a password' do
    admin.password = nil
    expect(admin).to_not be_valid
  end

  it 'does not allow duplicate emails' do
    create(:admin, email: 'admin@example.com')
    duplicate_admin = build(:admin, email: 'admin@example.com')
    expect(duplicate_admin).to_not be_valid
  end
end
