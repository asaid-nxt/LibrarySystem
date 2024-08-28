require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  include Devise::Test::ControllerHelpers

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user] # Map to the correct Devise scope
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:user_attributes) { attributes_for(:user) }

      let(:valid_attributes) do
        {
          user: {
            email: user_attributes[:email],
            password: user_attributes[:password],
            password_confirmation: user_attributes[:password]
          }
        }
      end

      it 'creates a new user and returns a success message' do
        expect {
          post :create, params: valid_attributes, as: :json
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Signed up successfully.")
      end
    end

    context 'with invalid attributes' do
      let(:invalid_attributes) do
        {
          user: {
            email: '',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'does not create a user and returns an error message' do
        expect {
          post :create, params: invalid_attributes, as: :json
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("Email can't be blank")
      end
    end
  end
end
