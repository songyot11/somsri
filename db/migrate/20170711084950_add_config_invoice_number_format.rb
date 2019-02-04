class AddConfigInvoiceNumberFormat < ActiveRecord::Migration[5.0]
  def change
    add_column :site_configs, :display_schools_year_with_invoice_id, :boolean, default: true
  end
end
