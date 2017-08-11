module StudentsHelper

  def student_link(student)
    if !student.nil?
      ActionController::Base.helpers.link_to "#{student.full_name_with_title}", edit_student_path(student.id)
    end
  end

  def student_link_by_hash (name, id)
    if name && id
      ActionController::Base.helpers.link_to "#{name}", edit_student_path(id)
    end
  end

end
