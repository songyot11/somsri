class UsersController < ApplicationController
  before_action :authenticate_user!

  def me
    render json: { roles: current_user.roles.collect{ |r| r.name } }
  end

  def site_config
    render json: SiteConfig.get_cache
  end
end
