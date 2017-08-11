class AddTaxToSiteConfig < ActiveRecord::Migration[5.0]
  def change
    add_column :site_configs, :tax, :boolean, default: true
  end
end
