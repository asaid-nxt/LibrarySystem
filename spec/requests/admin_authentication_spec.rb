# spec/integration/admin_authentication_spec.rb
require 'swagger_helper'

RSpec.describe 'Admin Authentication', type: :request do

  path '/admins/sign_in' do
    post 'Admin Sign in' do
      tags 'Admin Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :admin, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: ['email', 'password']
      }

      response '200', 'successful sign in' do
        let(:admin) { { email: 'admin@example.com', password: 'password' } }
        skip 'Skipping test execution, but generating docs' # Add this line
        run_test!
      end

      response '401', 'unauthorized' do
        let(:admin) { { email: 'wrong@example.com', password: 'wrong_password' } }
        skip 'Skipping test execution, but generating docs' # Add this line
        run_test!
      end
    end
  end

  path '/admins/sign_out' do
    delete 'Admin Sign out' do
      tags 'Admin Authentication'
      produces 'application/json'

      response '204', 'successful sign out' do
        skip 'Skipping test execution, but generating docs' # Add this line
        run_test!
      end
    end
  end

end
