class AddKtbCustomerCodeToSiteConfig < ActiveRecord::Migration[5.0]
  def change
    add_column :site_configs, :export_ktb_payroll, :boolean, default: false
  end
end
