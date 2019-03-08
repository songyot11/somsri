class AddColumnUserToEmployee < ActiveRecord::Migration[5.0]
  def up
  	remove_reference :class_permisions, :user, foreign_key: true
  	add_reference :class_permisions, :employee, foreign_key: true
  	add_column :employees, :name, :string
  	add_column :employees, :full_name, :string
  end

  def down
  	add_reference :class_permisions, :user, foreign_key: true
  	remove_reference :class_permisions, :employee, foreign_key: true
  	remove_column :employees, :name, :string
  	remove_column :employees, :full_name, :string
  end
end
