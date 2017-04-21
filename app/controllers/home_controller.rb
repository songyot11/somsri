class HomeController < ApplicationController
  def index
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
