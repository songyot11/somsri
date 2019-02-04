class AddDefineReturnDateToInventoryRequest < ActiveRecord::Migration[5.0]
  def change
  	add_column :inventory_requests, :define_return_date , :datetime
  end
end
