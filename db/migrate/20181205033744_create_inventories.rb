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
    	t.string :date_add
      t.timestamps
    end
  end
end