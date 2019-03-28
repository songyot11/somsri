class UsersController < ApplicationController
  before_action :authenticate_user!

  def me
    render json: { roles: current_user.roles.collect{ |r| r.name } }
  end

  def role_employees
  	id = params[:id]
  	puts "id----------"
  	puts id
  	user = User.find(id)
  	render json: { roles: user.roles.collect{ |r| r.name } }
  end

  def site_config
    render json: SiteConfig.get_cache
  end
end
