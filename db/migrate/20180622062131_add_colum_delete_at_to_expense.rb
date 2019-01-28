class AddColumDeleteAtToExpense < ActiveRecord::Migration[5.0]
  def change
    add_column :expenses, :deleted_at, :datetime
  end
end
