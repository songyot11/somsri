class Alumni < ApplicationRecord
  belongs_to :student

  def self.newByStudent(student)
    if student && student.instance_of?(Student)
      grade = student.grade.name if student.grade
      classroom = student.classroom.name if student.classroom
      return Alumni.new({
        student_id: student.id,
        name: student.full_name_with_title,
        nickname: student.full_name.blank? ? student.nickname_english : student.nickname,
        student_number: student.student_number,
        status: student.status,
        graduated_year: SchoolSetting.school_year,
        graduated_semester: SchoolSetting.current_semester,
        grade: grade,
        classroom: classroom
      })
    end
  end

  def grade_classroom
    if !self.grade.blank?
      if self.classroom.blank?
        return "#{self.grade}"
      else
        return "#{self.grade} (#{self.classroom})"
      end
    else
      if self.classroom.blank?
        return nil
      else
        return "#{self.classroom}"
      end
    end
  end

  def self.search(search)
    if search
      where("name ILIKE ? OR nickname ILIKE ? OR student_number::text ILIKE ? OR grade ILIKE ? OR classroom ILIKE ? ",
       "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%")
    else
      all
    end
  end

  def as_json(options={})
    if options[:index]
      return {
        name: self.name,
        nickname: self.nickname,
        student_number: self.student_number,
        status: self.status,
        graduated_year: self.graduated_year,
        graduated_semester: self.graduated_semester,
        grade_classroom: self.grade_classroom,
        student_id: self.student_id
      }
    elsif options[:years]
      return self.graduated_year
    elsif options[:status]
      return self.status
    else
      super()
    end
  end

end
