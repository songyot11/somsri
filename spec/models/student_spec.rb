describe Student do

  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }

  let(:employee) do
    Employee.make!({ school_id: school.id, pin: "1111", classroom: "1A" })
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
        classroom: '2B' ,
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
    teacher_attendance_lists
  end

  it 'generate new list for student' do
    students[0].classroom = "2B"
    students[0].save
    students[0].reload
    expect(students[0].student_lists.length).to eq(1)
    expect(students[0].student_lists[0].list.name).to eq("2B")
  end

  describe 'in invoice screen' do
    it 'display full name with nick name (in parentheses)' do
      student = Student.make(first_name: 'Xavi', last_name: 'Pepe', nickname: 'Tom')
      full_name = student.invoice_screen_full_name_display
      expect(full_name).to eq('Xavi Pepe (Tom)')
    end

    it 'display full name without parentheses, if there is no nick name' do
      student = Student.make(first_name: 'Xavi', last_name: 'Pepe', nickname: '')
      full_name = student.invoice_screen_full_name_display
      expect(full_name).to eq('Xavi Pepe')
    end
  end
end
