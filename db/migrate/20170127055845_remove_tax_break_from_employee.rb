class RemoveTaxBreakFromEmployee < ActiveRecord::Migration[5.0]
  def change
    remove_column :employees, :tax_break
  end
end
