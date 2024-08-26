class Admins::PasswordsController < Devise::PasswordsController
  respond_to :json

  # POST /admins/password
  def create
    self.resource = resource_class.send_reset_password_instructions(create_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      render json: { message: "Reset password instructions sent" }, status: :ok
    else
      render json: { error: resource.errors.full_messages.join(', ') }, status: :not_found
    end
  end

  # PUT /admins/password
  def update
    self.resource = resource_class.reset_password_by_token(update_params)
    yield resource if block_given?

    if resource.errors.empty?
      render json: { message: "Password updated successfully" }, status: :ok
    else
      render json: { error: resource.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  private

  def create_params
    params.require(:admin).permit(:email)
  end

  def update_params
    params.require(:admin).permit(:reset_password_token, :password, :password_confirmation)
  end
end
