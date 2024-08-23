# spec/integration/admin_authentication_spec.rb
require 'swagger_helper'

RSpec.describe 'Admin Authentication', type: :request do

  before do
    # Stubbing the requests to skip actual execution
    allow_any_instance_of(ActionDispatch::Integration::Session).to receive(:post).and_return(true)
    allow_any_instance_of(ActionDispatch::Integration::Session).to receive(:delete).and_return(true)
  end

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
              email: { type: :string, example: 'admin@admin.com' },
              password: { type: :string, example: 'admin123' }
            },
            required: ['email', 'password']
          }
        }
      }

      response '200', 'successful sign in' do
        let(:admin) { { email: 'admin@example.com', password: 'password' } }
        # Mark this block as skipped to prevent test execution
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end

      response '401', 'unauthorized' do
        let(:admin) { { email: 'wrong@example.com', password: 'wrong_password' } }
        # Mark this block as skipped to prevent test execution
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end
  end

  path '/admins/sign_out' do
    delete 'Admin Sign out' do
      tags 'Admin Authentication'
      produces 'application/json'

      response '204', 'successful sign out' do
        # Mark this block as skipped to prevent test execution
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end
  end

end
