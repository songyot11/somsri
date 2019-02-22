class AddReferencInventoryRequest < ActiveRecord::Migration[5.0]
  def change
  	add_reference :inventory_requests, :inventory
  	add_column :inventory_requests, :return_date , :datetime
  	add_column :inventory_requests, :request_count, :integer
  	add_column :inventory_requests, :request_type, :string
  end
end
