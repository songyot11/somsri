describe Student do

  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }

  let(:grade){grade = Grade.create(
    name: "Kindergarten 1"
  )}

  let(:classrooms) do
    [
      Classroom.make!({name: "1A", grade_id: grade.id}),
      Classroom.make!({name: "2B", grade_id: grade.id}),
      Classroom.make!({name: "9S", grade_id: grade.id})
    ]
  end

  let(:employee) do
    Employee.make!({ school_id: school.id, pin: "1111", classroom: classrooms[0] })
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
      StudentList.make!({ student_id: students[0].id, list_id: lists[0].id}),
      StudentList.make!({ student_id: students[1].id, list_id: lists[0].id})
    ]
  end

  let(:parent) do
    [
      Parent.make!({full_name: 'ฉันเป็น สุภาพบุรุษนะครับ', mobile: "080-0987654"})
    ]
  end

  let(:relationships) do
    [
      Relationship.make!({ name: 'Father' }),
      Relationship.make!({ name: 'Mother' })
    ]
  end

  let(:studentsparent) do
    [
      StudentsParent.make!({student_id: students[0].id , parent_id: parent[0].id, relationship_id: relationships[0].id})
    ]
  end

  before do
    SiteConfig.make!({ student_number_leading_zero: 6 })
    classrooms
    student_lists
    studentsparent
    teacher_attendance_lists
  end

  it 'should return student number = 000023' do
    expect(students[0].student_number).to eq("000023")
  end

  it 'generate new list for student' do
    students[0].classroom = classrooms[1]
    students[0].save
    students[0].reload
    expect(students[0].student_lists.length).to eq(1)
    expect(students[0].student_lists[0].list.name).to eq(classrooms[1].name)
  end

  it 'generate new list for student' do
    students[0].classroom = classrooms[2]
    students[0].save
    students[1].classroom = classrooms[2]
    students[1].save
    students[2].classroom = classrooms[2]
    students[2].save

    students[0].reload
    students[1].reload
    students[2].reload

    expect(students[0].student_lists.length).to eq(1)
    expect(students[0].student_lists[0].list.name).to eq(classrooms[2].name)

    expect(students[1].student_lists.length).to eq(1)
    expect(students[1].student_lists[0].list.name).to eq(classrooms[2].name)

    expect(students[2].student_lists.length).to eq(1)
    expect(students[2].student_lists[0].list.name).to eq(classrooms[2].name)
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

  it 'should soft delete student\'s parent when student are graduate' do
    expect(Student.where(id: students[0].id).exists?).to be_truthy
    expect(Parent.where(id: parent[0].id).exists?).to be_truthy
    students[0].graduate
    expect(Student.where(id: students[0].id).exists?).to be_falsey
    expect(Parent.where(id: parent[0].id).exists?).to be_falsey

    expect(Student.with_deleted.where(id: students[0].id).exists?).to be_truthy
    expect(Parent.with_deleted.where(id: parent[0].id).exists?).to be_truthy
  end
end
