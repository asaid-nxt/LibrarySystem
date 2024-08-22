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

        # Example data for the test
        let(:genre) { 'Fantasy' } # Example genre filter

        # Run the test
        run_test!
      end

     
    end
  end
end
