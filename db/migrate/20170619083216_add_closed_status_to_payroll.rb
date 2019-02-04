class AddClosedStatusToPayroll < ActiveRecord::Migration[5.0]
  def change
    add_column :payrolls, :closed, :boolean
  end
end
