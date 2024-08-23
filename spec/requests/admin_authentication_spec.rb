# spec/integration/admin_authentication_spec.rb
require 'swagger_helper'

RSpec.describe 'Admin Authentication', type: :request do

  before do
    # Stubbing the requests to skip actual execution
    allow_any_instance_of(ActionDispatch::Integration::Session).to receive(:post).and_return(true)
    allow_any_instance_of(ActionDispatch::Integration::Session).to receive(:delete).and_return(true)
    allow_any_instance_of(ActionDispatch::Integration::Session).to receive(:patch).and_return(true)
    allow_any_instance_of(ActionDispatch::Integration::Session).to receive(:put).and_return(true)
  end

  path '/admins/sign_in' do
    get 'Admin Sign in page' do
      tags 'Admin Authentication'
      produces 'application/json'

      response '200', 'sign in page' do
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end

    post 'Admin Sign in' do
      tags 'Admin Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :admin, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'admin@admin.com' },
          password: { type: :string, example: 'admin123' }
        },
        required: ['email', 'password']
      }

      response '200', 'successful sign in' do
        let(:admin) { { email: 'admin@example.com', password: 'password' } }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end

      response '401', 'unauthorized' do
        let(:admin) { { email: 'wrong@example.com', password: 'wrong_password' } }
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
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end
  end

  path '/admins/password/new' do
    get 'New password reset page' do
      tags 'Admin Authentication'
      produces 'application/json'

      response '200', 'password reset page' do
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end
  end

  path '/admins/password/edit' do
    get 'Edit password page' do
      tags 'Admin Authentication'
      produces 'application/json'

      response '200', 'edit password page' do
        skip 'Skipping test execution, but generating docs' do
          run_test!
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
          email: { type: :string, example: 'admin@admin.com' }
        },
        required: ['email']
      }

      response '200', 'password reset email sent' do
        let(:admin) { { email: 'admin@admin.com' } }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end

      response '404', 'email not found' do
        let(:admin) { { email: 'nonexistent@admin.com' } }
        skip 'Skipping test execution, but generating docs' do
          run_test!
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
        let(:admin) { { reset_password_token: 'reset-token', password: 'newpassword', password_confirmation: 'newpassword' } }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end

      response '422', 'unprocessable entity' do
        let(:admin) { { reset_password_token: 'reset-token', password: 'short', password_confirmation: 'mismatch' } }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end

    put 'Update password' do
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
        let(:admin) { { reset_password_token: 'reset-token', password: 'newpassword', password_confirmation: 'newpassword' } }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end

      response '422', 'unprocessable entity' do
        let(:admin) { { reset_password_token: 'reset-token', password: 'short', password_confirmation: 'mismatch' } }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end
  end

  path '/admins/sign_up' do
    get 'New registration page' do
      tags 'Admin Authentication'
      produces 'application/json'

      response '200', 'registration page' do
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end

    post 'Create admin' do
      tags 'Admin Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :admin, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'newadmin@admin.com' },
          password: { type: :string, example: 'password' },
          password_confirmation: { type: :string, example: 'password' }
        },
        required: ['email', 'password', 'password_confirmation']
      }

      response '201', 'successful registration' do
        let(:admin) { { email: 'newadmin@example.com', password: 'password', password_confirmation: 'password' } }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end

      response '422', 'unprocessable entity' do
        let(:admin) { { email: 'invalidemail', password: 'short', password_confirmation: 'different' } }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end
  end

  path '/admins/cancel' do
    get 'Cancel registration page' do
      tags 'Admin Authentication'
      produces 'application/json'

      response '200', 'cancel registration page' do
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end
  end

  path '/admins/edit' do
    get 'Edit registration page' do
      tags 'Admin Authentication'
      produces 'application/json'

      response '200', 'edit registration page' do
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end

    patch 'Update admin' do
      tags 'Admin Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :admin, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'updatedadmin@example.com' },
          password: { type: :string, example: 'newpassword' },
          password_confirmation: { type: :string, example: 'newpassword' }
        },
        required: ['email', 'password', 'password_confirmation']
      }

      response '200', 'admin updated' do
        let(:admin) { { email: 'updatedadmin@example.com', password: 'newpassword', password_confirmation: 'newpassword' } }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end

      response '422', 'unprocessable entity' do
        let(:admin) { { email: 'invalidemail', password: 'short', password_confirmation: 'mismatch' } }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end

    put 'Update admin' do
      tags 'Admin Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :admin, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'updatedadmin@example.com' },
          password: { type: :string, example: 'newpassword' },
          password_confirmation: { type: :string, example: 'newpassword' }
        },
        required: ['email', 'password', 'password_confirmation']
      }

      response '200', 'admin updated' do
        let(:admin) { { email: 'updatedadmin@example.com', password: 'newpassword', password_confirmation: 'newpassword' } }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end

      response '422', 'unprocessable entity' do
        let(:admin) { { email: 'invalidemail', password: 'short', password_confirmation: 'mismatch' } }
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end

    delete 'Delete admin' do
      tags 'Admin Authentication'
      produces 'application/json'

      response '204', 'admin deleted' do
        skip 'Skipping test execution, but generating docs' do
          run_test!
        end
      end
    end
  end
end
