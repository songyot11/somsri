class AddClassroomIdToStudent < ActiveRecord::Migration[5.0]
  def change
    add_reference :students, :classroom, index: true
    add_foreign_key :students, :classrooms
  end
end
