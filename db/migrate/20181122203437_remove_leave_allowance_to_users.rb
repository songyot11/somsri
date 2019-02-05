class RemoveLeaveAllowanceToUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :leave_allowance, :integer
  end
end
