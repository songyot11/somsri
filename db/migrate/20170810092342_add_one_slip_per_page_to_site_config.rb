class AddOneSlipPerPageToSiteConfig < ActiveRecord::Migration[5.0]
  def change
    add_column :site_configs, :one_slip_per_page, :boolean, default: false
  end
end
