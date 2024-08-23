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
              password: { type: :string, example: 'password123' }
            },
            required: ['email', 'password', 'password_confirmation']
          }
        },
        required: ['user']
      }

      response '201', 'user created' do
        let(:user) { { user: { email: 'newuser@example.com', password: 'password123'} } }
        skip 'Skipping test execution, only generating docs'
      end

      response '422', 'invalid request' do
        let(:user) { { user: { email: 'newuser@example.com', password: 'password123'} } }
        skip 'Skipping test execution, only generating docs'
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
        skip 'Skipping test execution, only generating docs'
      end

      response '401', 'unauthorized' do
        let(:user) { { user: { email: 'wrong@test.com', password: 'wrongpassword' } } }
        skip 'Skipping test execution, only generating docs'
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

        skip 'Skipping test execution, only generating docs'
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

        skip 'Skipping test execution, only generating docs'
      end

      response '401', 'unauthorized' do
        skip 'Skipping test execution, only generating docs'
      end
    end
  end

end
