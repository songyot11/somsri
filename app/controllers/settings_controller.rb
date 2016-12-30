class SettingsController < ApplicationController
  authorize_resource :class => :setting
  skip_before_action :verify_authenticity_token, :only => [:update_current_user, :update_password]

  # GET /settings
  def index
    render json: current_user, status: :ok
  end

  # PATCH /settings
  def update_current_user
    if current_user.update(params_user)
      render json: current_user, status: :ok
    else
      render json: {error: current_user.errors.full_message}, status: :bad_request
    end
  end

  # PATCH /settings/update_password
  def update_password
    @user = User.find(current_user.id)
    if @user.update_with_password(params_password)
      bypass_sign_in(@user)
      render json: current_user, status: :ok
    else
      render json: {error: "password invalid."}, status: :bad_request
    end
  end

  private
    def params_password
      params.require(:user).permit(:password, :password_confirmation, :current_password)
    end

    def params_user
      params.require(:user).permit(:name, :email)
    end
end
