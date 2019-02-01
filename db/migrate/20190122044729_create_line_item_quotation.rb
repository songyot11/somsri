class CreateLineItemQuotation < ActiveRecord::Migration[5.0]
  def change
    create_table :line_item_quotations do |t|
      t.string :detail
      t.float :amount
      t.integer :quotation_id

      t.timestamps
    end
  end
end
