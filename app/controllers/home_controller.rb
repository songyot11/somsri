class HomeController < ApplicationController
  def index
    if !current_user
      if SiteConfig.get_cache.web_cms
        redirect_to comfy_cms_render_page_path
      else
        redirect_to new_user_session_path
      end
    end
  end

  def changelog
  end

  # /auth_api?id_token=STRING
  def auth_api
    pin = params['pin']
    employee = Employee.where(pin: pin).first
    render json: employee and return if employee
    render json: { errors: "Invalid PIN" }, status: 422 and return
  end
end
