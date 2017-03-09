class HomeController < ApplicationController
  def index
  end

  def changelog
  end

  # /auth_api?id_token=STRING
  def auth_api
    pin = params['pin']
    user = User.where(pin: pin).first
    render json: user and return if user
    render json: { errors: "Invalid PIN or user not registered" }, status: 422 and return
  end
end
