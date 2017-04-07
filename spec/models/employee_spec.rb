describe Employee do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }

  let(:employee) do
    Employee.make!({ school_id: school.id, pin: "1111" })
  end

  let(:students) do
    [
      Student.make!({
        first_name: 'มั่งมี',
        last_name: 'ศรีสุข',
        nickname: 'รวย' ,
        gender_id: 1 ,
        grade_id: 2 ,
        classroom: '1A' ,
        classroom_number: 13 ,
        student_number: 23 ,
      }),
      Student.make!({
        first_name: 'สมศรี',
        last_name: 'ณ บานาน่าโค๊ดดิ้ง',
        nickname: 'กล้วย' ,
        gender_id: 2 ,
        grade_id: 4 ,
        classroom: '1A' ,
        classroom_number: 14 ,
        student_number: 22 ,
        birthdate: Time.now
      }),
      Student.make!({
        first_name: 'สมศรี',
        last_name: 'ณ บานาน่าโค๊ดดิ้ง',
        nickname: 'กั้ง' ,
        gender_id: 2 ,
        grade_id: 4 ,
        classroom: '1B' ,
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
    student_lists
    user.add_role :admin
    login_as(user, scope: :user)
    teacher_attendance_lists
  end

  it 'generate new list for employee' do
    employee.classroom = "1B"
    employee.save
    employee.generate_teacher_attendance_lists
    employee.reload

    found_list = nil
    employee.lists.each do |list|
      if list.name == "1B"
        found_list = list
      end
    end
    expect(employee.pin).not_to be_nil
    expect(found_list).not_to be_nil
    expect(found_list.name).to eq("1B")
    expect(found_list.get_students.collect(&:student_number)).to include(21)
  end

  it 'link relationship between exist list and new employee' do
    em = Employee.make!({ school_id: school.id })
    em.classroom = "1A"
    em.save
    em.generate_teacher_attendance_lists
    em.reload

    found_list = nil
    em.lists.each do |list|
      if list.name == "1A"
        found_list = list
      end
    end
    expect(employee.pin).not_to be_nil
    expect(found_list).not_to be_nil
    expect(found_list.id).to eq(lists[0].id)
    expect(found_list.get_students.collect(&:student_number)).to include(22)
  end

  it 'do nothing if employee already have list' do
    employee.generate_teacher_attendance_lists
    employee.reload

    found_list = nil
    employee.lists.each do |list|
      if list.name == "1A"
        found_list = list
      end
    end
    expect(employee.pin).not_to be_nil
    expect(found_list).not_to be_nil
    expect(found_list.id).to eq(lists[0].id)
    expect(found_list.get_students.collect(&:student_number)).to include(22)
  end

end
