if Rails.env.production?
  Raven.configure do |config|
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    config.dsn = Figaro.env.SENTRY_KEY
  end
end