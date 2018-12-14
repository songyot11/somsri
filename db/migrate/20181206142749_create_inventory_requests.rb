class CreateInventoryRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :inventory_requests do |t|
			t.integer :user_id
      t.integer :inventory_id
    	t.string :request_date
      t.integer :inventory_status
      t.timestamps
    end
  end
end
