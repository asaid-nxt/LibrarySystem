require 'rails_helper'

RSpec.describe Users::PasswordsController, type: :controller do
  # Include Devise Test Helpers
  include Devise::Test::ControllerHelpers

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    let!(:user) { FactoryBot.create(:user, email: 'user@example.com') }

    context 'when email is valid' do
      it 'sends reset password instructions' do
        post :create, params: { user: { email: user.email } }, as: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Reset password instructions sent")
      end
    end

    context 'when email is invalid' do
      it 'returns an error' do
        post :create, params: { user: { email: 'invalid@example.com' } }, as: :json

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to be_present
      end
    end
  end

  describe 'PUT #update' do
    let!(:user) { FactoryBot.create(:user, email: 'user@example.com') }
    let(:reset_password_token) { user.send(:set_reset_password_token) }

    context 'when the reset token and passwords are valid' do
      it 'updates the password successfully' do
        put :update, params: {
          user: {
            reset_password_token: reset_password_token,
            password: 'newpassword',
            password_confirmation: 'newpassword'
          }
        }, as: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Password updated successfully")
      end
    end

    context 'when passwords do not match' do
      it 'returns an error' do
        put :update, params: {
          user: {
            reset_password_token: reset_password_token,
            password: 'newpassword',
            password_confirmation: 'wrongpassword'
          }
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to include("Password confirmation doesn't match Password")
      end
    end

    context 'when reset token is invalid' do
      it 'returns an error' do
        put :update, params: {
          user: {
            reset_password_token: 'invalid_token',
            password: 'newpassword',
            password_confirmation: 'newpassword'
          }
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to include("Reset password token is invalid")
      end
    end
  end
end
