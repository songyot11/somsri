class AddExportKbankPayrollToSiteConfigs < ActiveRecord::Migration[5.0]
  def change
    add_column :site_configs, :export_kbank_payroll, :boolean, default: false
  end
end
