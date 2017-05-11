class SettingsController < ApplicationController
  authorize_resource :class => :setting
  skip_before_action :verify_authenticity_token, :only => [:update_current_user, :update_password]

  # GET /settings
  def index
    render json: getSetting(), status: :ok
  end

  # PATCH /settings
  def update_current_user
    User.transaction do
      if current_user.update(params_user) && current_user.school.update(params_school)
        render json: getSetting(), status: :ok
      else
        render json: {error: "Cannot update settings."}, status: :bad_request
      end
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
    def getSetting
      {
        user: current_user,
        school: current_user.school
      }
    end

    def params_password
      params.require(:user).permit(:password, :password_confirmation, :current_password)
    end

    def params_school
      params.require(:school).permit(:name, :tax_id, :address, :zip_code, :phone, :fax, :email)
    end

    def params_user
      params.require(:user).permit(:name, :email)
    end
end
