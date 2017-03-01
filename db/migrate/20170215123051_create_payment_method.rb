class CreatePaymentMethod < ActiveRecord::Migration[5.0]
  def change
    create_table :payment_methods do |t|
      t.string :payment_method
      t.string :cheque_bank_name
      t.string :cheque_number
      t.string :cheque_date
      t.string :transfer_bank_name
      t.string :transfer_date

      t.integer :invoice_id
    end
  end
end
