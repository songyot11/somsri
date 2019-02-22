class CreateInventoryRepairs < ActiveRecord::Migration[5.0]
  def change
    create_table :inventory_repairs do |t|
    	t.belongs_to :inventory
    	t.belongs_to :inventory_request
    	t.belongs_to :employee
        t.string :employee_name
    	t.string :item_name
    	t.string :serial_number
    	t.string :reason
    	t.datetime :repair_date
    	t.datetime :return_date
    	t.float :price
    	t.string :receipt
    	t.integer :repair_status
      t.timestamps
    end
  end
end