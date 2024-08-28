require 'rails_helper'

RSpec.describe Borrowing, type: :model do
  let(:user) { create(:user) }
  let(:book) { create(:book) }
  let(:borrowing) { build(:borrowing, user: user, book: book) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:book) }
  end

  describe 'validations' do
    it { should validate_presence_of(:borrowed_at) }
    it { should validate_presence_of(:due_date) }

    it 'validates uniqueness of book_id scoped to user_id' do
      create(:borrowing, user: user, book: book)
      duplicate_borrowing = build(:borrowing, user: user, book: book)
      expect(duplicate_borrowing).not_to be_valid
      expect(duplicate_borrowing.errors[:book_id]).to include('has already been borrowed')
    end
  end

  describe '.overdue' do
    let!(:overdue_borrowing) { create(:borrowing, user: user, book: book, due_date: 1.week.ago, returned_at: nil) }
    let!(:returned_borrowing) { create(:borrowing, user: user, book: create(:book), due_date: 1.week.ago, returned_at: 2.days.ago) }

    it 'includes only overdue borrowings' do
      expect(Borrowing.overdue).to include(overdue_borrowing)
      expect(Borrowing.overdue).not_to include(returned_borrowing)
    end
  end
end
