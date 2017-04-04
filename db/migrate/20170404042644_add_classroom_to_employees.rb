class AddClassroomToEmployees < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :grade_id, :integer
    add_column :employees, :classroom, :string
  end
end
