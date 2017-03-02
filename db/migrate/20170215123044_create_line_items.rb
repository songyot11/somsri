class CreateLineItems < ActiveRecord::Migration[5.0]
  def change
    create_table :line_items do |t|
      t.string :detail
      t.float :amount
      t.integer :invoice_id

      t.timestamps
    end
  end
end
