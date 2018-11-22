class AddLeaveAllowanceToEmployee < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :leave_allowance, :integer, default: 0
  end
end
