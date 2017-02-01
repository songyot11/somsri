class AddHouseLoanInterest < ActiveRecord::Migration[5.0]
  def change
    add_column :tax_reductions, :house_loan_interest, :decimal, default: 0, null: false
  end
end
