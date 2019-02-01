class RemoveInvoiceIdFromQuotations < ActiveRecord::Migration[5.0]
  def change
    remove_column :quotations, :invoice_id, :integer
  end
end
