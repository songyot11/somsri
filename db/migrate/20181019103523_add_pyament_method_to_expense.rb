class AddPyamentMethodToExpense < ActiveRecord::Migration[5.0]
  def change
    add_column :expenses, :payment_method, :string
    add_column :expenses, :cheque_bank_name, :string
    add_column :expenses, :cheque_number, :string
    add_column :expenses, :cheque_date, :string
    add_column :expenses, :transfer_bank_name, :string
    add_column :expenses, :transfer_date, :string
  end
end
