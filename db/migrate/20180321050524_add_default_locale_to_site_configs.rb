class AddDefaultLocaleToSiteConfigs < ActiveRecord::Migration[5.0]
  def change
    add_column :site_configs, :default_locale, :string
  end
end
