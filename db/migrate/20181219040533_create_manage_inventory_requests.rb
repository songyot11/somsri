class CreateManageInventoryRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :manage_inventory_requests do |t|
    	t.belongs_to :inventory_request
     	t.integer :step
      t.string :save_by
      t.string :accept
      t.string :save_by_step2
      t.string :date_purchase
      t.string :date_send
      t.string :price
      t.string :save_by_step3
      t.string :get_date
      t.string :buy_slip
      t.string :end_warranty
      t.string :save_by_step4
      t.string :send_to_employee_name
      t.string :send_to_employee_id
      t.string :save_by_step5
      t.timestamps
    end
  end
end
