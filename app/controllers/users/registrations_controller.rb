class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  # POST /resource
  def create
    user = User.new(sign_up_params)
    if user.save
      render json: { message: "Signed up successfully.", user: user }, status: :created
    else
      render json: { error: user.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
