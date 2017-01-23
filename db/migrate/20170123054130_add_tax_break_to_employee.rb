class AddTaxBreakToEmployee < ActiveRecord::Migration[5.0]
  def change
  	add_column :employees, :tax_break, :decimal, default: 0
  end
end
