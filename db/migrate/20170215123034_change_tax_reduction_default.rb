class ChangeTaxReductionDefault < ActiveRecord::Migration[5.0]
  def change
  	change_column_default :tax_reductions, :expenses, 60000
  end
end
