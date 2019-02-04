class ChangeTotalCost < ActiveRecord::Migration[5.0]
  def change
    remove_column :expenses, :total_cost
    add_column :expenses, :total_cost, :float
  end
end
