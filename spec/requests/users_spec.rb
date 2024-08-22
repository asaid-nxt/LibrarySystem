require 'swagger_helper'

RSpec.describe 'Users API', type: :request do

  # User sign-up route
  path '/users' do
    post 'Signs up a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'newuser@example.com' },
              password: { type: :string, example: 'password123' },
              password_confirmation: { type: :string, example: 'password123' }
            },
            required: ['email', 'password', 'password_confirmation']
          }
        },
        required: ['user']
      }

      response '201', 'user created' do
        let(:user) { { user: { email: 'newuser@example.com', password: 'password123', password_confirmation: 'password123' } } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:user) { { user: { email: 'newuser@example.com', password: 'password123', password_confirmation: 'mismatch' } } }
        run_test!
      end
    end
  end

  # User sign-in route
  path '/users/sign_in' do
    post 'Signs in a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'user@example.com' },
              password: { type: :string, example: 'password123' }
            },
            required: ['email', 'password']
          }
        },
        required: ['user']
      }

      response '200', 'user signed in' do
        let!(:user) { User.create!(email: 'test@test.com', password: '123456') }
        let(:user) { { user: { email: 'test@test.com', password: '123456' } } }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:user) { { user: { email: 'wrong@test.com', password: 'wrongpassword' } } }
        run_test!
      end
    end
  end

  # User sign-out route
  path '/users/sign_out' do
    delete 'Signs out a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      response '204', 'user signed out' do
        let!(:user) { User.create!(email: 'test@test.com', password: '123456') }

        before do
          sign_in(user)
        end

        run_test! do |response|
          expect(response.status).to eq(204)
        end
      end
    end
  end

  # Current user details route
  path '/users/me' do
    get 'Retrieves current user details' do
      tags 'Users'
      produces 'application/json'

      response '200', 'user details' do
        let!(:user) { User.create!(email: 'test@test.com', password: '123456') }

        before do
          sign_in(user)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['email']).to eq('test@test.com')
        end
      end

      response '401', 'unauthorized' do
        run_test!
      end
    end
  end

end
