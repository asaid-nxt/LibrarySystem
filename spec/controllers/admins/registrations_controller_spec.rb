require 'rails_helper'

RSpec.describe Admins::RegistrationsController, type: :controller do
  include Devise::Test::ControllerHelpers

  before do
    @request.env["devise.mapping"] = Devise.mappings[:admin] # Map to the correct Devise scope
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:admin_attributes) { attributes_for(:admin) }

      let(:valid_attributes) do
        {
          admin: {
            email: admin_attributes[:email],
            password: admin_attributes[:password],
            password_confirmation: admin_attributes[:password]
          }
        }
      end

      it 'creates a new admin and returns a success message' do
        expect {
          post :create, params: valid_attributes, as: :json
        }.to change(Admin, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Signed up successfully.")
      end
    end

    context 'with invalid attributes' do
      let(:invalid_attributes) do
        {
          admin: {
            email: '',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'does not create a admin and returns an error message' do
        expect {
          post :create, params: invalid_attributes, as: :json
        }.not_to change(Admin, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to include("Email can't be blank")
      end
    end
  end
end
