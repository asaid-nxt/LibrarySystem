# spec/requests/user_authentication_spec.rb
require 'swagger_helper'
include Warden::Test::Helpers



RSpec.describe 'User Authentication', type: :request do

  include Devise::Test::IntegrationHelpers
  # Define user credentials
  let(:user_email) { 'test@example.com' }
  let(:user_password) { 'password123' }

  # Create a user before running tests
  let!(:user) { User.create!(email: user_email, password: user_password) }

  path '/users/sign_in' do
    post 'User Sign in' do
      tags 'User Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
                type: :object,
                properties: {
                  user: {
                    type: :object,
                    properties: {
                      email: { type: :string, example: 'user@example.com' },
                      password: { type: :string, example: 'password' }
                    },
                    required: ['email', 'password']
                  }
                },
                required: ['user']
              }

      response '200', 'successful sign in' do
        let(:sign_in_user) { { email: user_email, password: user_password } }

        before do
          post '/users/sign_in', params: { user: sign_in_user }, as: :json
        end


        it 'returns a success message and user details' do
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(['Logged in successfully.', 'You are already signed in.']).to include(json_response['message'])
          expect(json_response['user']['email']).to eq(user_email) if json_response['message'] == 'Logged in successfully.'
        end
      end

      response '401', 'unauthorized' do
        let(:sign_in_user) { { email: 'wrong@example.com', password: 'wrongpassword' } }

        before do
          post '/users/sign_in', params: { user: sign_in_user }, as: :json
        end

        it 'returns an error message' do
          expect(response).to have_http_status(:unauthorized)
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq('Invalid email or password')
        end
      end
    end
  end

  path '/users/sign_out' do
    delete 'User Sign out' do
      tags 'User Authentication'
      produces 'application/json'

      response '200', 'Logged out successfully' do
        before do
          post '/users/sign_in', params: { user: { email: user_email, password: user_password } }, as: :json
          delete '/users/sign_out', as: :json
        end

        it 'returns a success message' do
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq('Logged out successfully.')
        end
      end
    end
  end

  path '/users/password' do
    post 'Send reset password instructions' do
      tags 'User Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
          email: { type: :string, example: 'user@example.com' }
        },
        required: ['email']
        }
      },
        required: ['user']
      }



      response '200', 'password reset email sent' do
        let(:reset_email) { { email: 'test@example.com' } }

        before { post '/users/password', params: { user: reset_email }, as: :json }

        it 'returns a success message' do
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq('Reset password instructions sent')
        end
      end

      response '404', 'email not found' do
        let(:nonexistent_email) { { email: 'nonexistent@example.com' } }

        before { post '/users/password', params: { user: nonexistent_email }, as: :json }

        it 'returns an error message' do
          expect(response).to have_http_status(:not_found)
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq('Email not found')
        end
      end
    end

    patch 'Update password' do
      tags 'User Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          reset_password_token: { type: :string, example: 'reset-token' },
          password: { type: :string, example: 'newpassword' },
          password_confirmation: { type: :string, example: 'newpassword' }
        },
        required: ['reset_password_token', 'password', 'password_confirmation']
      }

      response '200', 'password updated' do
        let(:reset_password_token) { user.send(:set_reset_password_token) }
        let(:update_password) { { reset_password_token: reset_password_token, password: 'newpassword', password_confirmation: 'newpassword' } }

        before { patch '/users/password', params: { user: update_password }, as: :json }

        it 'returns a success message' do
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq('Password updated successfully')
        end
      end

      response '422', 'unprocessable entity' do
        let(:reset_password_token) { user.send(:set_reset_password_token) }
        let(:invalid_password_update) { { reset_password_token: reset_password_token, password: 'short', password_confirmation: 'mismatch' } }

        before { patch '/users/password', params: { user: invalid_password_update }, as: :json }

        it 'returns an error message' do
          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to include('Password is too short')
          expect(json_response['error']).to include("Password confirmation doesn't match Password")
        end
      end
    end
  end


  path '/users' do
    post 'Create user' do
      tags 'User Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
          type: :object,
          properties: {
          email: { type: :string, example: 'newuser@example.com' },
          password: { type: :string, example: 'password' },
          password_confirmation: { type: :string, example: 'password' }
        },
        required: ['email', 'password', 'password_confirmation']
        }
        },
        required: ['user']
      }


      response '201', 'successful registration' do
        let(:new_user) { { email: 'newuser@example.com', password: 'password', password_confirmation: 'password' } }

        before { post '/users', params: { user: new_user }, as: :json }

        it 'returns a success message and user details' do
          expect(response).to have_http_status(:created)
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq('Signed up successfully.')
          expect(json_response['user']['email']).to eq('newuser@example.com')
        end
      end

      response '422', 'unprocessable entity' do
        let(:invalid_registration) { { email: 'invalidemail', password: 'short', password_confirmation: 'different' } }

        before { post '/users', params: { user: invalid_registration }, as: :json }

        it 'returns error messages' do
          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to include('Email is invalid')
          expect(json_response['error']).to include("Password confirmation doesn't match Password")
          expect(json_response['error']).to include('Password is too short')
        end
      end
    end
  end


  User.delete(:user)
end
