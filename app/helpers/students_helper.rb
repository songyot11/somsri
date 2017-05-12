module StudentsHelper

  def student_link_with_full_name student
    if !student.nil?
      link_to "#{student.full_name_with_title}", edit_student_path(student)
    end
  end

end
