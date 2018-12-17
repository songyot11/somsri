class CreateInventoryRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :inventory_requests do |t|
			t.string :user_name
      t.string :item_name
      t.string :description
      t.float :price
    	t.string :request_date
      t.integer :inventory_status
      t.timestamps
    end
  end
end
