# app/controllers/admins/registrations_controller.rb
class Admins::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  # POST /admins
  def create
    admin = Admin.new(sign_up_params)
    if admin.save
      render json: { message: "Signed up successfully.", admin: admin }, status: :created
    else
      render json: { error: admin.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end
end
