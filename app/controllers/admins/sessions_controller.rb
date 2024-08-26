class Admins::SessionsController < Devise::SessionsController
  respond_to :json

  # POST /admins/sign_in
  def create
      admin = Admin.find_for_authentication(email: params[:admin][:email])
      if admin && admin.valid_password?(params[:admin][:password])
        sign_in(admin)
        render json: { message: "Logged in successfully.", admin: admin }, status: :ok
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
  end

  # DELETE /admins/sign_out
  def destroy
    if admin_signed_in?
      sign_out(current_admin)
      render json: { message: "Logged out successfully." }, status: :ok
    else
      render json: { error: "No admin signed in." }, status: :unprocessable_entity
    end
  end
end
