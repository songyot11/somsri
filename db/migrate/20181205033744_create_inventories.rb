class CreateInventories < ActiveRecord::Migration[5.0]
  def change
    create_table :inventories do |t|
    	t.string :item_name
    	t.string :serial_number
    	t.string :model
    	t.string :description
    	t.float :price
    	t.string :date_purchase
    	t.string :category
      t.string :category_barcode
    	t.string :date_add
      t.string :end_warranty
      t.integer :employee_id
      t.timestamps
    end
  end
end