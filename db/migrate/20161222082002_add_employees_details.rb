class AddEmployeesDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :nickname, :string
    add_column :employees, :start_date, :datetime
  end
end
