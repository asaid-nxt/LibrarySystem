require 'swagger_helper'

RSpec.describe 'Books API', type: :request do
  path '/books' do

    get 'Retrieves all books, optionally filtered by genre' do
      tags 'Books'
      produces 'application/json'
      description 'Retrieves a list of all books. Optionally, you can filter by genre.'

      # Query Parameter for filtering by genre
      parameter name: :genre, in: :query, type: :string, description: 'Filter books by genre'

      response '200', 'Books found' do
        # Schema for the response
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

        let(:genre) { 'Fantasy' } # Example genre filter
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end

    post 'Creates a new book' do
      tags 'Books'
      consumes 'application/json'
      produces 'application/json'
      description 'Creates a new book entry.'

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
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end

      response '422', 'Invalid request' do
        let(:book) { { title: '', author: 'F. Scott Fitzgerald', genre: 'Novel', isbn: '9780743273565', available_copies: 10 } }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
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
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end

      response '404', 'Book not found' do
        let(:id) { 'invalid' }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end

    patch 'Updates a specific book' do
      tags 'Books'
      consumes 'application/json'
      produces 'application/json'
      description 'Updates a specific book by its ID.'

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
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end

      response '422', 'Invalid request' do
        let(:id) { Book.create!(title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Novel', isbn: '9780743273565', available_copies: 10).id }
        let(:book) { { title: '', author: 'F. Scott Fitzgerald', genre: 'Novel', isbn: '9780743273565', available_copies: 10 } }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end

    delete 'Deletes a specific book' do
      tags 'Books'
      produces 'application/json'
      description 'Deletes a specific book by its ID.'

      response '204', 'Book deleted' do
        let(:id) { Book.create!(title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', genre: 'Novel', isbn: '9780743273565', available_copies: 10).id }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end

      response '404', 'Book not found' do
        let(:id) { 'invalid' }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end
  end
end
