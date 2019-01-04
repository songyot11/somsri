class AddCommentInventoryRequest < ActiveRecord::Migration[5.0]
  def change
  	add_column :inventory_requests, :comment, :string
  	add_reference :inventory_requests, :employee
  end

end
