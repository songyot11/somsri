class AddLeaveAllowanceToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :leave_allowance, :integer, default: 0
  end
end
