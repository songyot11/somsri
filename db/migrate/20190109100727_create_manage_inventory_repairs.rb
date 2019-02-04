class CreateManageInventoryRepairs < ActiveRecord::Migration[5.0]
  def change
    create_table :manage_inventory_repairs do |t|
    	t.belongs_to :inventory_repair
    	t.integer :step
    	t.string :step1_save_by
    	t.datetime :repair_date
    	t.string :supplier_name
    	t.datetime :appointment_date
    	t.string :step2_save_by
    	t.datetime :return_date
    	t.float :price
    	t.string :receipt
    	t.string :step3_save_by
    	t.integer :employee_id
    	t.string :step4_save_by
      t.timestamps
    end
  end
end
