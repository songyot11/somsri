class ChangeColumnDefaultDefaultLocale < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:site_configs, :default_locale, 'th')
  end
end
