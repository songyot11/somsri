class ApplicationController < ActionController::Base
  include CanCan::ControllerAdditions
  protect_from_forgery with: :exception
  before_action :set_cache_buster, :set_locale
  after_action :set_csrf_cookie_for_ng

  def set_locale
    @locale = params[:locale] || session['locale'] ||
              SiteConfig.get_cache.default_locale || I18n.default_locale

    I18n.locale = @locale
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to '/', :alert => exception.message
  end

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def isDate(date_string)
    begin
       Date.parse(date_string)
       return true
    rescue
       return false
    end
  end

  def qry_date_range(qry, data_field, start_date, end_date)
    if start_date && end_date
      qry = qry.where(created_at: start_date..end_date)
    elsif start_date
      qry = qry.where(data_field.gt(start_date))
    elsif end_date
      qry = qry.where(data_field.lt(end_date))
    end
    return qry
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def flash_message_list(message_list)
    html = message_list.collect { |obj| "<li>#{obj}</li>" }.join('')
    return "<u>#{html}</u>"
  end

  protected
    def verified_request?
      super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
    end

    def is_json(string)
      begin
        !!JSON.parse(string)
      rescue
        false
      end
    end
end
