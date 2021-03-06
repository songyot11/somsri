require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SomsriPayroll
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.time_zone = 'Bangkok'
    config.i18n.default_locale = :th
    config.i18n.available_locales = [:th, :en]
    config.filter_parameters << :password
  end
end

Dir["#{Rails.root}/lib/modules/*.rb"].each {|file| require file }

