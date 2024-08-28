require 'rails_helper'

RSpec.describe BorrowingsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:book) { create(:book, available_copies: 1) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
    book.update(available_copies: 1)  # Ensure available_copies starts at 1
  end

  describe 'POST #create' do
    context 'when the book is available' do
      it 'creates a borrowing and decreases available copies' do
        expect {
          post :create, params: { book_id: book.id }, as: :json
        }.to change(user.borrowings, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['book_id']).to eq(book.id)

        book.reload
        expect(book.available_copies).to eq(0)
      end
    end

    context 'when the book is not available' do
      before { book.update(available_copies: 0) }

      it 'returns an error' do
        post :create, params: { book_id: book.id }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Book is not available for borrowing')
      end
    end

    context 'when the user has already borrowed the book' do
      before { create(:borrowing, user: user, book: book) }

      it 'returns an error' do
        post :create, params: { book_id: book.id }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('You have already borrowed this book')
      end
    end
  end

  describe 'POST #return' do
    let!(:borrowing) { create(:borrowing, user: user, book: book, returned_at: nil) }

    context 'when the borrowing record exists and is not returned' do
      it 'marks the book as returned and updates the borrowing' do
        post :return, params: { book_id: book.id }, as: :json
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Book returned successfully')

        borrowing.reload
        expect(borrowing.returned_at).to_not be_nil

        book.reload
        expect(book.available_copies).to eq(2)
      end
    end

    context 'when the borrowing record is not found or already returned' do
      it 'returns an error' do
        borrowing.update(returned_at: Time.current)
        post :return, params: { book_id: book.id }, as: :json
        expect(response).to have_http_status(:not_found)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Borrowing record not found or already returned')
      end
    end
  end

  describe 'GET #overdue' do
    let!(:overdue_borrowing) { create(:borrowing, user: user, book: book, due_date: 3.days.ago) }

    it 'returns a list of overdue books' do
      get :overdue, as: :json
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response[0]['book_id']).to eq(book.id)
    end
  end

  describe 'GET #user' do
    let!(:borrowing) { create(:borrowing, user: user, book: book) }

    it 'returns the user\'s borrowed books' do
      get :user, as: :json
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response[0]['title']).to eq(book.title)
    end
  end
end
