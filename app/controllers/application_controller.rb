class ApplicationController < ActionController::Base
  include CanCan::ControllerAdditions
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to new_user_session_path, :alert => exception.message
  end

  def isDate(date_string)
    begin
       Date.parse(date_string)
       return true
    rescue ArgumentError
       return false
    end
  end
end
