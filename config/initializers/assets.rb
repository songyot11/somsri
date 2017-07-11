# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

Rails.application.config.assets.precompile += %w( application_invoice.js )
Rails.application.config.assets.precompile += %w( application_invoice.css )
Rails.application.config.assets.precompile += %w( application_payroll.js )
Rails.application.config.assets.precompile += %w( application_payroll.css )
Rails.application.config.assets.precompile += %w( application_rollcall.js )
Rails.application.config.assets.precompile += %w( application_rollcall.css )
Rails.application.config.assets.precompile += %w( application_main.js )
Rails.application.config.assets.precompile += %w( application_main.css )
Rails.application.config.assets.precompile += %w( print_student_list.js )
Rails.application.config.assets.precompile += %w( custom_bootstrap_table.js )
Rails.application.config.assets.precompile += %w( preview_image.js )
