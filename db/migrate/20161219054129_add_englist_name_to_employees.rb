class AddEnglistNameToEmployees < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :first_name_thai, :string
    add_column :employees, :last_name_thai, :string
  end
end
