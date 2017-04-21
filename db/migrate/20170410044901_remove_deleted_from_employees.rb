class RemoveDeletedFromEmployees < ActiveRecord::Migration[5.0]
  def change
    remove_column :employees, :deleted, :boolean
  end
end
