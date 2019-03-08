class HomeController < ApplicationController
  def index 
    if !current_user
      if SiteConfig.get_cache.web_cms
        redirect_to comfy_cms_render_page_path
      else
        redirect_to new_user_session_path
      end
    else
      @is_outstanding = SiteConfig.get_cache.outstanding_notification
    end
  end

  def changelog
  end

  def language
    session['locale'] = params[:locale] || I18n.default_locale
    I18n.locale = session['locale']
    redirect_to params[:weburl]
  end

  def locale
    default_lang = I18n.locale.to_s
    lang = params[:lang] || default_lang
    yml_path = Rails.root.join('config/locales', "#{lang}.yml")

    unless File.exist?(yml_path)
      lang = default_lang
      yml_path = Rails.root.join('config/locales', "#{lang}.yml")
    end

    lang_file = File.read(yml_path)
    lang_json = JSON.pretty_generate(YAML.load(lang_file)[lang])

    render json: lang_json
  end

  # /auth_api?id_token=STRING
  def auth_api
    pin = params['pin']
    employee = Employee.where(pin: pin).first
    render json: employee and return if employee
    render json: { errors: "Invalid PIN" }, status: 422 and return
  end
end
