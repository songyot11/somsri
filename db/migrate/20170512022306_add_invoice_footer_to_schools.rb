class AddInvoiceFooterToSchools < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :invoice_footer, :text
  end
end
