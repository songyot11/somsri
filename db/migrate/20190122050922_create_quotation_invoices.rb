class CreateQuotationInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :quotation_invoices do |t|
      t.integer :quotation_id
      t.integer :invoice_id
    end
  end
end
