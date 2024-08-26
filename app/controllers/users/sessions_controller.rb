class Users::SessionsController < Devise::SessionsController
  respond_to :json

  # POST /resource/sign_in
  def create
    if user_signed_in?
      render json: { message: "Logged in successfully.", user: current_user }, status: :ok
    else
      user = User.find_for_authentication(email: params[:user][:email])
      if user && user.valid_password?(params[:user][:password])
        sign_in(user)
        render json: { message: "Logged in successfully.", user: user }, status: :ok
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end
  end


  # DELETE /resource/sign_out
  def destroy
    if user_signed_in?
      sign_out(current_user)
      render json: { message: "Logged out successfully." }, status: :ok
    else
      render json: { error: "No user signed in." }, status: :unprocessable_entity
    end
  end


end
