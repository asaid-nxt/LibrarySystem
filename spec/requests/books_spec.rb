require 'swagger_helper'

RSpec.describe 'Books API', type: :request do
  # Assuming you have a method `authenticate_admin!` for admin authentication
  let!(:admin) { Admin.create!(email: 'admin@example.com', password: 'password123') }
  let!(:user) { User.create!(email: 'user@example.com', password: 'password123') }

  # Simulate an admin being signed in for the tests that require admin privileges
  before(:each) do
    sign_in admin
  end

  path '/books' do
    get 'Retrieves all books, optionally filtered by genre' do
      tags 'Books'
      produces 'application/json'
      description 'Retrieves a list of all books. Optionally, you can filter by genre.'

      parameter name: :genre, in: :query, type: :string, description: 'Filter books by genre'
      parameter name: :page, in: :query, type: :integer, description: 'Page number for pagination'
      parameter name: :per_page, in: :query, type: :integer, description: 'Number of books per page'

      response '200', 'Books found' do
        schema type: :object,
               properties: {
                 books: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       title: { type: :string },
                       author: { type: :string },
                       genre: { type: :string },
                       isbn: { type: :string },
                       available_copies: { type: :integer }
                     },
                     required: ['id', 'title', 'author', 'genre', 'isbn', 'available_copies']
                   }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     next_page: { type: :integer, nullable: true },
                     prev_page: { type: :integer, nullable: true },
                     total_pages: { type: :integer },
                     total_count: { type: :integer }
                   },
                   required: ['current_page', 'total_pages', 'total_count']
                 }
               },
               required: ['books', 'meta']

        let(:genre) { 'Fantasy' }
        let(:page) { 1 }
        let(:per_page) { 10 }

        run_test!
      end
    end



    path '/books/available' do
      get 'Retrieves all available books (Authenticated Users Only)' do
        tags 'Books'
        produces 'application/json'
        description 'Retrieves a list of all books that are currently available. Only accessible by authenticated users.'

        # Simulate user authentication
        before do
          sign_in user
        end

        response '200', 'Available books found' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     title: { type: :string },
                     author: { type: :string },
                     genre: { type: :string },
                     isbn: { type: :string },
                     available_copies: { type: :integer }
                   },
                   required: ['id', 'title', 'author', 'genre', 'isbn', 'available_copies']
                 }

          let!(:book1) { Book.create!(title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Novel', isbn: '9780743273565', available_copies: 10) }
          let!(:book2) { Book.create!(title: '1984', author: 'George Orwell', genre: 'Dystopian', isbn: '9780451524935', available_copies: 5) }

          run_test!
        end

        response '401', 'Unauthorized (Unauthenticated user)' do
          before do
            sign_out user
          end

          run_test!
        end
      end
    end


    path '/books/borrowed' do
      get 'Retrieves all borrowed books (Authenticated Users Only)' do
        tags 'Books'
        produces 'application/json'
        description 'Retrieves a list of all books that are currently borrowed by users along with their due dates. Only accessible by authenticated users.'

        # Simulate user authentication
        before do
          sign_in user
        end

        response '200', 'Borrowed books found' do
          schema type: :array,
                 items: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     title: { type: :string },
                     author: { type: :string },
                     genre: { type: :string },
                     isbn: { type: :string },
                     available_copies: { type: :integer },
                     due_date: { type: :string, format: 'date-time' }
                   },
                   required: ['id', 'title', 'author', 'genre', 'isbn', 'due_date']
                 }

          let!(:book1) { Book.create!(title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Novel', isbn: '9780743273565', available_copies: 0) }
          let!(:book2) { Book.create!(title: '1984', author: 'George Orwell', genre: 'Dystopian', isbn: '9780451524935', available_copies: 0) }
          let!(:borrowing1) { Borrowing.create!(user: user, book: book1, borrowed_at: 2.days.ago, due_date: 5.days.from_now) }
          let!(:borrowing2) { Borrowing.create!(user: user, book: book2, borrowed_at: 1.day.ago, due_date: 4.days.from_now) }

          run_test!
        end

        response '401', 'Unauthorized (Unauthenticated user)' do
          before do
            sign_out user
          end

          run_test!
        end
      end
    end




    post 'Creates a new book (Admin Only)' do
      tags 'Books'
      consumes 'application/json'
      produces 'application/json'
      description 'Creates a new book entry. Only accessible by admins.'

      parameter name: :book, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: 'The Great Gatsby' },
          author: { type: :string, example: 'F. Scott Fitzgerald' },
          genre: { type: :string, example: 'Novel' },
          isbn: { type: :string, example: '9780743273565' },
          available_copies: { type: :integer, example: 10 }
        },
        required: ['title', 'author', 'genre', 'isbn', 'available_copies']
      }

      response '201', 'Book created' do
        let(:book) { { title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Novel', isbn: '9780743273565', available_copies: 10 } }
        run_test!
      end

      response '401', 'Unauthorized (Non-admin user)' do
        before do
          sign_out admin
        end

        let(:book) { { title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Novel', isbn: '9780743273565', available_copies: 10 } }
        run_test!
      end
    end
  end

  path '/books/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ID of the book'

    get 'Retrieves a specific book' do
      tags 'Books'
      produces 'application/json'
      description 'Retrieves a specific book by its ID.'

      response '200', 'Book found' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 author: { type: :string },
                 genre: { type: :string },
                 isbn: { type: :string },
                 available_copies: { type: :integer }
               },
               required: ['id', 'title', 'author', 'genre', 'isbn', 'available_copies']

        let(:id) { Book.create!(title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Novel', isbn: '9780743273565', available_copies: 10).id }
        run_test!
      end
    end

    patch 'Updates a specific book (Admin Only)' do
      tags 'Books'
      consumes 'application/json'
      produces 'application/json'
      description 'Updates a specific book by its ID. Only accessible by admins.'

      parameter name: :book, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: 'The Great Gatsby Updated' },
          author: { type: :string, example: 'F. Scott Fitzgerald' },
          genre: { type: :string, example: 'Novel' },
          isbn: { type: :string, example: '9780743273565' },
          available_copies: { type: :integer, example: 15 }
        },
        required: ['title', 'author', 'genre', 'isbn', 'available_copies']
      }

      response '200', 'Book updated' do
        let(:id) { Book.create!(title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Novel', isbn: '9780743273565', available_copies: 10).id }
        let(:book) { { title: 'The Great Gatsby Updated', author: 'F. Scott Fitzgerald', genre: 'Novel', isbn: '9780743273565', available_copies: 15 } }
        run_test!
      end

      response '401', 'Unauthorized (Non-admin user)' do
        before do
          sign_out admin
        end

        let(:id) { Book.create!(title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Novel', isbn: '9780743273565', available_copies: 10).id }
        let(:book) { { title: 'The Great Gatsby Updated', author: 'F. Scott Fitzgerald', genre: 'Novel', isbn: '9780743273565', available_copies: 15 } }
        run_test!
      end
    end

    delete 'Deletes a specific book (Admin Only)' do
      tags 'Books'
      produces 'application/json'
      description 'Deletes a specific book by its ID. Only accessible by admins.'

      response '204', 'Book deleted' do
        let(:id) { Book.create!(title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Novel', isbn: '9780743273565', available_copies: 10).id }
        run_test!
      end

      response '401', 'Unauthorized (Non-admin user)' do
        before do
          sign_out admin
        end

        let(:id) { Book.create!(title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Novel', isbn: '9780743273565', available_copies: 10).id }
        run_test!
      end
    end
  end
end
