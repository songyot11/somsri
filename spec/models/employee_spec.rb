describe Employee do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }

  let(:employee) do
    Employee.make!({ school_id: school.id, pin: "1111" })
  end

  let(:grade){grade = Grade.create(
    name: "Kindergarten 1"
  )}

  let(:classrooms) do
    [
      Classroom.make!({name: "1A", grade_id: grade.id}),
      Classroom.make!({name: "1B", grade_id: grade.id})
    ]
  end

  let(:students) do
    [
      Student.make!({
        first_name: 'มั่งมี',
        last_name: 'ศรีสุข',
        nickname: 'รวย' ,
        gender_id: 1 ,
        grade_id: grade.id,
        classroom: classrooms[0],
        classroom_number: 13 ,
        student_number: 23 ,
      }),
      Student.make!({
        first_name: 'สมศรี',
        last_name: 'ณ บานาน่าโค๊ดดิ้ง',
        nickname: 'กล้วย' ,
        gender_id: 2 ,
        grade_id: grade.id,
        classroom: classrooms[0],
        classroom_number: 14 ,
        student_number: 22 ,
        birthdate: Time.now
      }),
      Student.make!({
        first_name: 'สมศรี',
        last_name: 'ณ บานาน่าโค๊ดดิ้ง',
        nickname: 'กั้ง' ,
        gender_id: 2 ,
        grade_id: grade.id,
        classroom: classrooms[1],
        classroom_number: 14 ,
        student_number: 21 ,
        birthdate: Time.now
      })
    ]
  end

  let(:lists) do
    [
      List.make!({ name: "1A" })
    ]
  end

  let(:teacher_attendance_lists) do
    [
      TeacherAttendanceList.make!({ list_id: lists[0].id, employee_id: employee.id})
    ]
  end

  let(:student_lists) do
    [
      StudentList.make!({ student_id: students[0].id, list_id: lists[0].id }),
      StudentList.make!({ student_id: students[1].id, list_id: lists[0].id })
    ]
  end

  before do
    SiteConfig.make!({ student_number_leading_zero: 0 })
    classrooms
    employee
    lists
    student_lists
    user.add_role :admin
    login_as(user, scope: :user)
    teacher_attendance_lists
  end

  it 'generate new list for employee' do
    employee.classroom = classrooms[1]
    employee.save
    employee.reload

    expect(employee.lists.size).to eq(1)
    expect(employee.lists[0].name).to eq(classrooms[1].name)
    expect(employee.lists[0].get_students.collect(&:student_number)).to include("21")
  end

  it 'link relationship between exist list and new employee' do
    em = Employee.make!({ school_id: school.id })
    em.classroom = classrooms[0]
    em.save
    em.reload

    expect(employee.pin).not_to be_nil
    expect(em.lists.size).to eq(1)
    expect(em.lists[0].id).to eq(lists[0].id)
    expect(em.lists[0].get_students.collect(&:student_number)).to include("22")
  end

  it 'should use same list if list already exist' do
    employee.classroom = classrooms[0]
    employee.save
    employee.reload

    expect(employee.lists.size).to eq(1)
    expect(employee.lists[0].id).to eq(lists[0].id)
    expect(employee.lists[0].get_students.collect(&:student_number)).to include("22")
  end

  it 'should do nothing if employee.classroom not change' do
    employee.first_name = "firstname"
    employee.save
    employee.reload

    expect(employee.lists.size).to eq(0)
  end

  describe '#save' do
    it 'generate pin' do
      # use update_all to skip before_save
      Employee.where(id: employee.id).update_all(pin: nil)
      expect(employee.reload.pin).to be_nil
      employee.save
      expect(employee.reload.pin).to_not be_nil
    end
  end

end
