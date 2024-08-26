class Admins::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  # POST /admins
  def create
    admin = Admin.new(sign_up_params)
    if admin.save
      render json: { message: "Signed up successfully.", admin: admin }, status: :created
    else
      render json: { error: admin.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def sign_up_params
    params.require(:admin).permit(:email, :password, :password_confirmation)
  end
end
