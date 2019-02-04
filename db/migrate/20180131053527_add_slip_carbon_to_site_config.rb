class AddSlipCarbonToSiteConfig < ActiveRecord::Migration[5.0]
  def change
    add_column :site_configs, :slip_carbon, :boolean, default: false
  end
end
