class AddClassroomToEmployee < ActiveRecord::Migration[5.0]
  def change
    rename_column :employees, :classroom, :classroom_name
    add_reference :employees, :classroom, index: true
    add_foreign_key :employees, :classrooms

    Classroom.all.each do |classroom|
      Employee.where(classroom_name: classroom.name).update_all({ classroom_id: classroom.id })
    end
  end
end
