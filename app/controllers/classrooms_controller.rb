class ClassroomsController < ApplicationController
  load_and_authorize_resource

  # GET /classrooms
  def index
    @classrooms = Classroom.all.to_a
    if params[:next]
      output = []
      @classrooms.each do |classroom|
        output_classroom = {
          classroom: {
            id: classroom.id,
            name: classroom.grade_with_name
          },
          next_classroom: nil
        }
        @classrooms.each do |next_classroom|
          if next_classroom.id == classroom.next_id
            output_classroom[:next_classroom] = {
              id: next_classroom.id,
              name: next_classroom.grade_with_name
            }
          end
        end
        output << output_classroom
      end
      render json: output, status: :ok
    else
      render json: @classrooms, status: :ok
    end
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
        img: teacher.img_url.exists? ? teacher.img_url.expiring_url(10, :medium) : nil,
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
        img: teacher.img_url.exists? ? teacher.img_url.expiring_url(10, :medium) : nil,
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
        img: student.img_url.exists? ? student.img_url.expiring_url(10, :medium) : nil,
        name: student.invoice_screen_full_name_display,
        id: student.id
      }
    end
    render json: students, status: :ok
  end

  # GET /classrooms/:id/student_without_classroom
  def student_without_classroom
    students = []
    classroom_id = params[:id]
    exclude_ids = JSON.parse params[:exclude_ids]
    Student.where(classroom_id: [nil, '', classroom_id])
           .where.not(id: exclude_ids).each do |student|
      students << {
        img: student.img_url.exists? ? student.img_url.expiring_url(10, :medium) : nil,
        name: student.invoice_screen_full_name_display,
        id: student.id
      }
    end
    render json: students, status: :ok
  end

  # PATCH /classrooms/:id/update_list
  def update_list
    classroom = Classroom.where(id: params[:id]).first
    if classroom
      teacher_ids = params[:teacher_ids]
      if teacher_ids
        Employee.where(classroom_id: classroom.id).update_all(classroom_id: nil, grade_id: nil)
        Employee.where(id: teacher_ids).update(classroom_id: classroom.id, grade_id: classroom.grade_id)
      end
      student_ids = params[:student_ids]
      if student_ids
        Student.where(classroom_id: classroom.id).update_all(classroom_id: nil, grade_id: nil)
        Student.where(id: student_ids).update(classroom_id: classroom.id, grade_id: classroom.grade_id)
      end
      render json: ["SUCCESS"], status: :ok and return
    end
    render json: ["FAIL"], status: :ok
  end

  # PATCH /classrooms/student_promote
  def student_promote
    if params[:classroomOrder]
      classroomOrder = JSON.parse params[:classroomOrder]
      classroomOrder.each do |order|
        Classroom.where(id: order['id']).update(next_id: order['next_id'])
      end
    end
    _student_promote([nil, ''], true) # start with next_id = nil
    Classroom.find_by_sql(
      "SELECT * FROM classrooms c1
      JOIN classrooms c2 ON c1.id = c2.id
      WHERE c1.id = c2.next_id").each do |classroom|
      _student_promote(classroom.id, false) # start with next_id = id
    end
    render json: ["SUCCESS"], status: :ok
  end

  # DELETE /classrooms/1
  def destroy
    @classroom.destroy
    render json: { head: :no_content }, status: :ok
  end

  # POST /classrooms
  def create
    grade_id = create_classroom_params[:grade_id]
    classroom = create_classroom_params[:classroom]

    if Classroom.where("lower(name) = ?", classroom.downcase).where(grade_id: grade_id).count > 0
      render json: { dupplicate: true }, status: :ok
    else
      classroom =  Classroom.create(name: classroom, grade_id: grade_id)
      classroom.next_id = classroom.id
      classroom.save
      render json: { head: :no_content }, status: :ok
    end

  end

  private
  def _student_promote(next_id, is_graduated)
    Classroom.where(next_id: next_id).each do |classroom|
      if is_graduated
        Student.where(classroom_id: classroom.id).to_a.each do |student|
          student.graduate if student
        end
        _student_promote(classroom.id, false)
      elsif classroom.id != next_id
        Student.where(classroom_id: classroom.id).update_all(classroom_id: next_id)
        _student_promote(classroom.id, false)
      end
    end
  end

  def create_classroom_params
    result = params.require(:create_classroom).permit([
      :grade_id,
      :classroom
    ])
    return result
  end

end
