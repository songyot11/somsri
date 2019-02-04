class AddThaiPrefixToEmployees < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :prefix_thai, :string
  end
end
