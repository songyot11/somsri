class AddGradeToInvoice < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :grade_name, :string
  end
end
