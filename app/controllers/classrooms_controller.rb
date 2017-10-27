class ClassroomsController < ApplicationController
  load_and_authorize_resource

  # GET /classrooms
  def index
    @classrooms = Classroom.all.to_a
    render json: @classrooms, status: :ok
  end

  # GET /classroom_list
  def classroom_list
    classrooms = []
    Classroom.all.to_a.each do |classroom|
      teacher_count = Employee.where(classroom_id: classroom.id).count
      student_count = Student.where(classroom_id: classroom.id).count
      classrooms << {
        grade: classroom.grade ? classroom.grade.name : "",
        classroom: classroom.name,
        classroom_id: classroom.id,
        teacher_count: teacher_count,
        student_count: student_count
      }
    end
    render json: classrooms, status: :ok
  end
end
