class CreateExpenseItems < ActiveRecord::Migration[5.0]
  def change
    add_column :expenses, :total_cost, :string
    create_table :expense_items do |t|
      t.belongs_to :expense, index: true
      t.string :detail
      t.integer :amount
      t.float :cost
    end
  end
end
