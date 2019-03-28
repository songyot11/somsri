class UsersController < ApplicationController
  before_action :authenticate_user!

  def me
    render json: { roles: current_user.roles.pluck(:name) }
  end

  def role_employees
  	id = params[:id]
  	user = User.find(id)
  	render json: { roles: user.roles.pluck(:name) }
  end

  def site_config
    render json: SiteConfig.get_cache
  end
end
