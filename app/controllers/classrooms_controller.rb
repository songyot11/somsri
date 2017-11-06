class ClassroomsController < ApplicationController
  load_and_authorize_resource

  # GET /classrooms
  def index
    @classrooms = Classroom.all.to_a
    render json: @classrooms, status: :ok
  end

  # GET /classrooms/:id
  def show
    classroom = Classroom.find(params[:id])
    classroom_result = {
      classroom: classroom.name,
      grade: classroom.grade ? classroom.grade.name : ""
    }
    render json: classroom_result, status: :ok
  end

  # GET /classrooms/classroom_list
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

  # GET /classrooms/:id/teacher_list
  def teacher_list
    teachers = []
    classroom = Classroom.find(params[:id])
    Employee.where(classroom: classroom).each do |teacher|
      teachers << {
        img: teacher.img_url.exists? ? teacher.img_url.url(:medium) : nil,
        name: teacher.full_name_with_nickname,
        id: teacher.id
      }
    end
    render json: teachers, status: :ok
  end

  # GET /classrooms/:id/teacher_without_classroom
  def teacher_without_classroom
    teachers = []
    classroom_id = params[:id]
    exclude_ids = JSON.parse params[:exclude_ids]
    Employee.where(classroom_id: [nil, '', classroom_id])
            .where.not(id: exclude_ids).each do |teacher|
      teachers << {
        img: teacher.img_url.exists? ? teacher.img_url.url(:medium) : nil,
        name: teacher.full_name_with_nickname,
        id: teacher.id
      }
    end
    render json: teachers, status: :ok
  end

  # GET /classrooms/:id/student_list
  def student_list
    students = []
    classroom = Classroom.find(params[:id])
    Student.where(classroom: classroom).each do |student|
      students << {
        img: student.img_url.exists? ? student.img_url.url(:medium) : '',
        name: student.invoice_screen_full_name_display,
        id: student.id
      }
    end
    render json: students, status: :ok
  end

  # GET /classrooms/:id/student_without_classroom
  def student_without_classroom
    students = []
    Student.where.where(classroom_id: [nil, '']).each do |student|
      students << {
        img: student.img_url.exists? ? student.img_url.url(:medium) : nil,
        name: student.full_name_with_nickname,
        id: student.id
      }
    end
    render json: students, status: :ok
  end
end
