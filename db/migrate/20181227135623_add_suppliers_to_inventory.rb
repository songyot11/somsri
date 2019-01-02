class AddSuppliersToInventory < ActiveRecord::Migration[5.0]
  def change
  	add_reference :inventories, :supplier
  	add_column :manage_inventory_requests, :inventory_id, :integer
  end
end