class AddEnableQuotationToSiteConfig < ActiveRecord::Migration[5.0]
  def change
    add_column :site_configs, :enable_quotation, :boolean, default: false
  end
end
