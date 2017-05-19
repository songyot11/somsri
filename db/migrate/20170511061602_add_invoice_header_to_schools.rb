class AddInvoiceHeaderToSchools < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :invoice_header, :text
  end
end
