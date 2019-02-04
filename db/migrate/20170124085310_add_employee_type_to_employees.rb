class AddEmployeeTypeToEmployees < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :employee_type, :string
  end
end
