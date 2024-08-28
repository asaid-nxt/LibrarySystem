require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  # Include Devise test helpers
  include Devise::Test::ControllerHelpers

  let!(:user) { create(:user) }

  before do
    # Ensure Devise mapping is set before each test
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'logs in the user and returns success message' do
        post :create, params: { user: { email: user.email, password: user.password } }, as: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Logged in successfully.")
      end
    end

    context 'with invalid credentials' do
      it 'returns an unauthorized error' do
        post :create, params: { user: { email: user.email, password: 'wrongpassword' } }, as: :json
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Invalid email or password")
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user is signed in' do
      before do
        sign_in user # Sign in user for the test
      end

      it 'logs out the user and returns success message' do
        delete :destroy, as: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Logged out successfully.")
      end
    end

    context 'when no user is signed in' do
      it 'returns an error message' do
        delete :destroy, as: :json
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
