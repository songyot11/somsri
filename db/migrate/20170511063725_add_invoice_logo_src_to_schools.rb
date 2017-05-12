class AddInvoiceLogoSrcToSchools < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :invoice_logo_src, :string
  end
end
