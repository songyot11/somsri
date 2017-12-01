class MigrateStudentClassroom < ActiveRecord::Migration[5.0]
  def change
    Student.select(:classroom, :grade_id).group(:classroom, :grade_id).each do |student|
      if !student[:classroom].blank? && student.grade_id
        Classroom.create({
          name: student[:classroom],
          grade_id: student.grade_id
        })
      end
    end
    rename_column :students, :classroom, :classroom_name
    Classroom.all.each do |classroom|
      Student.where(classroom_name: classroom.name).update_all({ classroom_id: classroom.id })
    end
  end
end
