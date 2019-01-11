class CreateQuotations < ActiveRecord::Migration[5.0]
  def change
    create_table :quotations do |t|
      t.integer :student_id
      t.integer :parent_id
      t.integer :user_id
      t.integer :invoice_id
      t.string :payment_method_id
      t.integer :quotation_status
      t.text :remark
      t.string :school_year
      t.string :semester
      t.string :grade_name
      t.string :student_name
      t.string :parent_name
      t.string :user_name
      t.date :payment_date_start
      t.date :payment_date_end
      t.timestamps
    end
  end
end
