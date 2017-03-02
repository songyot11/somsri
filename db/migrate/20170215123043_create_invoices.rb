class CreateInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :invoices do |t|
      t.integer :student_id
      t.integer :parent_id
      t.integer :user_id
      t.text :remark
      t.string :payment_method_id
      t.string :cheque_bank_name
      t.string :cheque_number
      t.string :cheque_date
      t.string :transfer_bank_name
      t.string :transfer_date
      t.integer :invoice_status_id
      t.string :school_year
      t.string :semester

      t.timestamps
    end
  end
end
