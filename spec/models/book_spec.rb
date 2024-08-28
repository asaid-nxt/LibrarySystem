require 'rails_helper'

RSpec.describe Book, type: :model do
  let(:book) { create(:book) }

  describe 'associations' do
    it { should have_many(:borrowings) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:author) }
    it { should validate_presence_of(:genre) }
    it { should validate_presence_of(:isbn) }
    it { should validate_presence_of(:available_copies) }
  end

  describe 'scopes' do
    context '.by_genre' do
      it 'returns books filtered by genre' do
        fantasy_book = create(:book, genre: 'Fantasy')
        mystery_book = create(:book, genre: 'Mystery')

        expect(Book.by_genre('Fantasy')).to include(fantasy_book)
        expect(Book.by_genre('Fantasy')).not_to include(mystery_book)
      end
    end

    context '.available' do
      it 'returns books with available copies' do
        available_book = create(:book, available_copies: 5)
        unavailable_book = create(:book, available_copies: 0)

        expect(Book.available).to include(available_book)
        expect(Book.available).not_to include(unavailable_book)
      end
    end

    context '.borrowed' do
      it 'returns books with no available copies' do
        available_book = create(:book, available_copies: 5)
        unavailable_book = create(:book, available_copies: 0)

        expect(Book.borrowed).to include(unavailable_book)
        expect(Book.borrowed).not_to include(available_book)
      end
    end
  end

  describe '#borrowable?' do
    it 'returns true if there are available copies' do
      book.available_copies = 5
      expect(book.borrowable?).to be_truthy
    end

    it 'returns false if there are no available copies' do
      book.available_copies = 0
      expect(book.borrowable?).to be_falsey
    end
  end

  describe '#borrow!' do
    context 'when book is borrowable' do
      it 'decrements the available copies' do
        book.update(available_copies: 5)
        expect { book.borrow! }.to change { book.reload.available_copies }.by(-1)
      end
    end

    context 'when book is not borrowable' do
      it 'adds an error to the base' do
        book.update(available_copies: 0)
        book.borrow!
        expect(book.errors[:base]).to include('No copies available')
      end
    end
  end

  describe '#return!' do
    it 'increments the available copies' do
      book.update(available_copies: 5)
      expect { book.return! }.to change { book.reload.available_copies }.by(1)
    end
  end
end
