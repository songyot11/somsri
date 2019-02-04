class AddPrivateInfoToEmployees < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :address, :text
    add_column :employees, :tel, :string
    add_column :employees, :status, :string
    add_column :employees, :email, :string
  end
end
