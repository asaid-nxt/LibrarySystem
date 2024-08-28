require 'swagger_helper'

RSpec.describe 'Borrowings API', type: :request do
  let!(:book) { Book.create!(title: 'The Great Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Novel', isbn: '9780743273565', available_copies: 5) }
  let!(:user) { User.create!(email: 'user8@example.com', password: 'password') }
  let!(:admin) { Admin.create!(email: 'admin@example.com', password: 'password') }



  path '/books/{book_id}/borrowings' do
    post 'Borrow a book (Users only)' do
      tags 'Borrowings'
      consumes 'application/json'
      produces 'application/json'
      description 'Creates a new borrowing record for the current user.'

      parameter name: :book_id, in: :path, type: :integer, description: 'ID of the book to be borrowed'
      parameter name: :borrowed_at, in: :body, schema: {
        type: :object,
        properties: {
          borrowed_at: { type: :string, format: 'date-time', example: '2023-08-27T14:30:00Z' }
        },
        required: ['borrowed_at']
      }

      response '201', 'Borrowing created' do
        let(:book_id) { book.id }
        let(:borrowed_at) { 2.days.ago.iso8601 }

        before do
          sign_in user
          post "/books/#{book_id}/borrowings", params: { borrowed_at: borrowed_at }, as: :json
        end

        it 'creates a borrowing with the specified borrowed_at date' do
          expect(response).to have_http_status(:created)
          json_response = JSON.parse(response.body)
          json_borrowed_at = json_response['borrowed_at']
          # Parse both timestamps and compare
          expect(Time.parse(json_borrowed_at)).to be_within(1.second).of(Time.parse(borrowed_at))
        end
      end

      response '422', 'Book not available for borrowing' do
        let(:book_id) { book.id }
        let(:borrowed_at) { 2.days.ago.iso8601 }

        before do
          book.update(available_copies: 0)
          sign_in user
          post "/books/#{book_id}/borrowings", params: { borrowed_at: borrowed_at }, as: :json
        end

        it 'returns an error message' do
          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq('Book is not available for borrowing')
        end
      end

      response '401', 'Unauthorized borrowing attempt' do
        let(:book_id) { book.id }
        let(:borrowed_at) { 2.days.ago.iso8601 }

        it 'returns an unauthorized error' do
          post "/books/#{book_id}/borrowings", params: { borrowed_at: borrowed_at }, headers: { 'ACCEPT' => 'application/json' }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end




  path '/books/{book_id}/borrowings/return' do
    patch 'Return a borrowed book (Users only)' do
      tags 'Borrowings'
      consumes 'application/json'
      produces 'application/json'
      description 'Marks a borrowing as returned for the current user.'

      parameter name: :book_id, in: :path, type: :integer, description: 'ID of the book being returned'

      let!(:borrowing) { user.borrowings.create!(book: book, borrowed_at: Time.current, due_date: 2.weeks.from_now) }

      response '200', 'Book returned successfully' do
        let(:book_id) { book.id }
        before { sign_in user }

        run_test!
      end

      response '404', 'Borrowing record not found' do
        let(:book_id) { book.id }
        before do
          borrowing.update(returned_at: Time.current) # Simulate book already returned
          sign_in user
        end

        run_test!
      end

      response '401', 'Unauthorized return attempt' do
        let(:book_id) { book.id }

        it 'returns an unauthorized error' do
          patch "/books/#{book_id}/borrowings/return", headers: { 'ACCEPT' => 'application/json' }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  path '/borrowings/overdue' do
    get 'Retrieves a list of overdue borrowings (Users only)' do
      tags 'Borrowings'
      produces 'application/json'
      description 'Retrieves a list of all overdue borrowings for the current user.'

      response '200', 'Overdue borrowings found' do
        before do
          user.borrowings.create!(book: book, borrowed_at: 3.weeks.ago, due_date: 2.weeks.ago)
          sign_in user
        end

        run_test!
      end

      response '200', 'No overdue borrowings found' do
        before { sign_in user }

        run_test!
      end

      response '401', 'Unauthorized' do
        it 'returns an unauthorized error' do
          get "/borrowings/overdue", headers: { 'ACCEPT' => 'application/json' }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end


  path '/borrowings/user' do
    get 'Retrives a list of user borrowings (User only)' do
      tags 'Borrowings'
      produces 'application/json'
      description 'Retrieves a list of all borrowings for the current user.'

      response '200', 'Borrowed books found' do
        before do
          user.borrowings.create!(book: book, borrowed_at: Time.now, due_date: 2.weeks.from_now)
          sign_in user
        end
        run_test!
      end

      response '200', 'No borrowed books found' do
        before { sign_in user }

        run_test!
      end

      response '401', 'Unauthorized' do
        it 'returns an unauthorized error' do
          get "/borrowings/user", headers: { 'ACCEPT' => 'application/json' }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
