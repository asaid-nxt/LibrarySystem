require 'rails_helper'

RSpec.describe BooksController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:admin) { create(:admin) }
  let(:user) { create(:user) }
  let(:book) { create(:book) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:admin] # Map Devise to admin
  end

  describe 'GET #index' do
    it 'returns a list of books' do
      create_list(:book, 3) # Create multiple books

      get :index, format: :json
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['books'].length).to eq(3)
    end
  end

  describe 'GET #show' do
    it 'returns the details of a specific book' do
      get :show, params: { id: book.id }, format: :json
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(book.id)
      expect(json_response['title']).to eq(book.title)
    end
  end

  describe 'POST #create' do
    context 'as an admin' do
      before { sign_in admin }

      it 'creates a new book with valid attributes' do
        book_attributes = attributes_for(:book)

        expect {
          post :create, params: { book: book_attributes }, format: :json
        }.to change(Book, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['title']).to eq(book_attributes[:title])
      end

      it 'returns errors with invalid attributes' do
        invalid_attributes = { title: '', author: '', genre: '' }

        expect {
          post :create, params: { book: invalid_attributes }, format: :json
        }.not_to change(Book, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Title can't be blank")
      end
    end

    context 'as a non-admin' do
      before { sign_in user }

      it 'returns unauthorized' do
        book_attributes = attributes_for(:book)

        post :create, params: { book: book_attributes }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT #update' do
    context 'as an admin' do
      before { sign_in admin }

      it 'updates the book with valid attributes' do
        updated_attributes = { title: 'New Title' }

        put :update, params: { id: book.id, book: updated_attributes }, format: :json
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['title']).to eq('New Title')
      end

      it 'returns errors with invalid attributes' do
        invalid_attributes = { title: '' }

        put :update, params: { id: book.id, book: invalid_attributes }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Title can't be blank")
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'as an admin' do
      before { sign_in admin }

      it 'deletes a book' do
        book_to_delete = create(:book)

        expect {
          delete :destroy, params: { id: book_to_delete.id }, format: :json
        }.to change(Book, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end

      it 'returns an error if book cannot be deleted' do
        allow_any_instance_of(Book).to receive(:destroy).and_return(false)

        delete :destroy, params: { id: book.id }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Failed to delete book')
      end
    end
  end
end
