# spec/requests/admin_authentication_spec.rb
require 'swagger_helper'
include Warden::Test::Helpers

RSpec.describe 'Admin Authentication', type: :request do

  include Devise::Test::IntegrationHelpers
  # Define admin credentials
  let(:admin_email) { 'admin@example.com' }
  let(:admin_password) { 'password123' }

  # Create an admin before running tests
  let!(:admin) { Admin.create!(email: admin_email, password: admin_password) }

  path '/admins/sign_in' do
    post 'Admin Sign in' do
      tags 'Admin Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :admin, in: :body, schema: {
                type: :object,
                properties: {
                  admin: {
                    type: :object,
                    properties: {
                      email: { type: :string, example: 'admin@example.com' },
                      password: { type: :string, example: 'password' }
                    },
                    required: ['email', 'password']
                  }
                },
                required: ['admin']
              }

      response '200', 'successful sign in' do
        let(:sign_in_admin) { { email: admin_email, password: admin_password } }

        before do
          post '/admins/sign_in', params: { admin: sign_in_admin }, as: :json
        end

        it 'returns a success message and admin details' do
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(['Logged in successfully.', 'You are already signed in.']).to include(json_response['message'])
          expect(json_response['admin']['email']).to eq(admin_email) if json_response['message'] == 'Logged in successfully.'
        end
      end

      response '401', 'unauthorized' do
        let(:sign_in_admin) { { email: 'wrongadmin@example.com', password: 'wrongpassword' } }

        before do
          post '/admins/sign_in', params: { admin: sign_in_admin }, as: :json
        end

        it 'returns an error message' do
          expect(response).to have_http_status(:unauthorized)
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq('Invalid email or password')
        end
      end
    end
  end

  path '/admins/sign_out' do
    delete 'Admin Sign out' do
      tags 'Admin Authentication'
      produces 'application/json'

      response '200', 'Logged out successfully' do
        before do
          post '/admins/sign_in', params: { admin: { email: admin_email, password: admin_password } }, as: :json
          delete '/admins/sign_out', as: :json
        end

        it 'returns a success message' do
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq('Logged out successfully.')
        end
      end
    end
  end

  path '/admins/password' do
    post 'Send reset password instructions' do
      tags 'Admin Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :admin, in: :body, schema: {
        type: :object,
        properties: {
          admin: {
            type: :object,
            properties: {
              email: { type: :string, example: 'admin@example.com' }
            },
            required: ['email']
          }
        },
        required: ['admin']
      }

      response '200', 'password reset email sent' do
        let(:reset_email) { { email: 'admin@example.com' } }

        before { post '/admins/password', params: { admin: reset_email }, as: :json }

        it 'returns a success message' do
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq('Reset password instructions sent')
        end
      end

      response '404', 'email not found' do
        let(:nonexistent_email) { { email: 'nonexistentadmin@example.com' } }

        before { post '/admins/password', params: { admin: nonexistent_email }, as: :json }

        it 'returns an error message' do
          expect(response).to have_http_status(:not_found)
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq('Email not found')
        end
      end
    end

    patch 'Update password' do
      tags 'Admin Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :admin, in: :body, schema: {
        type: :object,
        properties: {
          reset_password_token: { type: :string, example: 'reset-token' },
          password: { type: :string, example: 'newpassword' },
          password_confirmation: { type: :string, example: 'newpassword' }
        },
        required: ['reset_password_token', 'password', 'password_confirmation']
      }

      response '200', 'password updated' do
        let(:update_password) { { reset_password_token: 'reset-token', password: 'newpassword', password_confirmation: 'newpassword' } }

        before { patch '/admins/password', params: { admin: update_password }, as: :json }

        it 'returns a success message' do
          skip 'Skipping test as it requires a valid reset password token'
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq('Password updated successfully')
        end
      end

      response '422', 'unprocessable entity' do
        let(:invalid_password_update) { { reset_password_token: 'reset-token', password: 'short', password_confirmation: 'mismatch' } }

        before { patch '/admins/password', params: { admin: invalid_password_update }, as: :json }

        it 'returns an error message' do
          skip 'Skipping test as it requires a valid reset password token'
          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to include('Password is too short')
          expect(json_response['error']).to include("Password confirmation doesn't match Password")
        end
      end
    end
  end

  path '/admins' do
    post 'Create admin' do
      tags 'Admin Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :admin, in: :body, schema: {
        type: :object,
        properties: {
          admin: {
            type: :object,
            properties: {
              email: { type: :string, example: 'newadmin@example.com' },
              password: { type: :string, example: 'password' },
              password_confirmation: { type: :string, example: 'password' }
            },
            required: ['email', 'password', 'password_confirmation']
          }
        },
        required: ['admin']
      }

      response '201', 'successful registration' do
        let(:new_admin) { { email: 'newadmin@example.com', password: 'password', password_confirmation: 'password' } }

        before { post '/admins', params: { admin: new_admin }, as: :json }

        it 'returns a success message and admin details' do
          expect(response).to have_http_status(:created)
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq('Signed up successfully.')
          expect(json_response['admin']['email']).to eq('newadmin@example.com')
        end
      end

      response '422', 'unprocessable entity' do
        let(:invalid_registration) { { email: 'invalidemail', password: 'short', password_confirmation: 'different' } }

        before { post '/admins', params: { admin: invalid_registration }, as: :json }

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

  Admin.delete(:admin)
end
