class AddSuppliersToInventory < ActiveRecord::Migration[5.0]
  def change
  	add_reference :inventories, :supplier
  end
end