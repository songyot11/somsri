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
      StudentList.make!({ student_id: students[1].id, list_id: lists[0].id}),
      StudentList.make!({ student_id: students[2].id, list_id: lists[0].id})
    ]
  end

  let(:parent) do
    [
      Parent.make!({full_name: 'ฉันเป็น สุภาพบุรุษนะครับ', mobile: "080-0987654"}),
      Parent.make!({full_name: 'แม่บ้าน ลูกสอง', mobile: "080-0980000"})
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
      StudentsParent.make!({student_id: students[0].id , parent_id: parent[0].id, relationship_id: relationships[0].id}),
      StudentsParent.make!({student_id: students[1].id , parent_id: parent[1].id, relationship_id: relationships[1].id}),
      StudentsParent.make!({student_id: students[2].id , parent_id: parent[1].id, relationship_id: relationships[1].id})
    ]
  end

  let(:roll_calls) do
    [
      RollCall.make!({ student_id: students[0].id, list_id: lists[0].id, round: "afternoon", status: "3", check_date: "2017-03-28" }),
      RollCall.make!({ student_id: students[0].id, list_id: lists[0].id, round: "morning", status: "3", check_date: "2017-04-28" }),
      RollCall.make!({ student_id: students[1].id, list_id: lists[0].id, round: "morning", status: "0", check_date: "2017-03-28" }),
      RollCall.make!({ student_id: students[2].id, list_id: lists[0].id, round: "morning", status: "0", check_date: "2017-03-28" })
    ]
  end

  before do
    SiteConfig.make!({ student_number_leading_zero: 6 })
    classrooms
    student_lists
    studentsparent
    teacher_attendance_lists
    roll_calls
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
    expect(StudentList.where(id: student_lists[0].id).exists?).to be_truthy
    expect(StudentsParent.where(id: studentsparent[0].id).exists?).to be_truthy
    expect(Relationship.where(id: relationships[0].id).exists?).to be_truthy
    expect(List.where(id: lists[0].id).exists?).to be_truthy
    expect(Alumni.exists?).to be_falsey

    students[0].graduate

    # create alumni with status = "จบการศึกษา"
    expect(Alumni.where(student_id: students[0].id).exists?).to be_truthy
    expect(Alumni.where(student_id: students[0].id).first.status).to eq "จบการศึกษา"

    # soft delete student
    expect(Student.where(id: students[0].id).exists?).to be_falsey
    expect(Student.with_deleted.where(id: students[0].id).exists?).to be_truthy

    # soft delete parent when destroy their last student
    expect(Parent.where(id: parent[0].id).exists?).to be_falsey
    expect(Parent.with_deleted.where(id: parent[0].id).exists?).to be_truthy

    # soft delete student_lists
    expect(StudentList.where(id: student_lists[0].id).exists?).to be_falsey
    expect(StudentList.with_deleted.where(id: student_lists[0].id).exists?).to be_truthy

    # soft delete studentsparent
    expect(StudentsParent.where(id: studentsparent[0].id).exists?).to be_falsey
    expect(StudentsParent.with_deleted.where(id: studentsparent[0].id).exists?).to be_truthy

    # do nothing for relationships
    expect(Relationship.where(id: relationships[0].id).exists?).to be_truthy

    # do nothing for lists
    expect(List.where(id: lists[0].id).exists?).to be_truthy
  end

  it 'should restore graduated student' do
    students[0].graduate
    expect(Student.where(id: students[0].id).exists?).to be_falsey

    Student.with_deleted.where(id: students[0].id).first.restore_recursively

    # restore to the same as before
    expect(Student.where(id: students[0].id).exists?).to be_truthy
    expect(Parent.where(id: parent[0].id).exists?).to be_truthy
    expect(StudentList.where(id: student_lists[0].id).exists?).to be_truthy
    expect(StudentsParent.where(id: studentsparent[0].id).exists?).to be_truthy
    expect(Relationship.where(id: relationships[0].id).exists?).to be_truthy
    expect(List.where(id: lists[0].id).exists?).to be_truthy
    expect(Alumni.exists?).to be_falsey
  end

  it 'should soft delete student\'s parent when student are resign' do
    expect(Student.where(id: students[0].id).exists?).to be_truthy
    expect(Parent.where(id: parent[0].id).exists?).to be_truthy
    expect(StudentList.where(id: student_lists[0].id).exists?).to be_truthy
    expect(StudentsParent.where(id: studentsparent[0].id).exists?).to be_truthy
    expect(Relationship.where(id: relationships[0].id).exists?).to be_truthy
    expect(List.where(id: lists[0].id).exists?).to be_truthy
    expect(Alumni.exists?).to be_falsey

    students[0].resign

    # create alumni with status = "ลาออก"
    expect(Alumni.where(student_id: students[0].id).exists?).to be_truthy
    expect(Alumni.where(student_id: students[0].id).first.status).to eq "ลาออก"

    # soft delete student
    expect(Student.where(id: students[0].id).exists?).to be_falsey
    expect(Student.with_deleted.where(id: students[0].id).exists?).to be_truthy

    # soft delete parent when destroy their last student
    expect(Parent.where(id: parent[0].id).exists?).to be_falsey
    expect(Parent.with_deleted.where(id: parent[0].id).exists?).to be_truthy

    # soft delete student_lists
    expect(StudentList.where(id: student_lists[0].id).exists?).to be_falsey
    expect(StudentList.with_deleted.where(id: student_lists[0].id).exists?).to be_truthy

    # soft delete studentsparent
    expect(StudentsParent.where(id: studentsparent[0].id).exists?).to be_falsey
    expect(StudentsParent.with_deleted.where(id: studentsparent[0].id).exists?).to be_truthy

    # do nothing for relationships
    expect(Relationship.where(id: relationships[0].id).exists?).to be_truthy

    # do nothing for lists
    expect(List.where(id: lists[0].id).exists?).to be_truthy
  end

  it 'should restore resign student' do
    students[0].resign
    expect(Student.where(id: students[0].id).exists?).to be_falsey

    Student.with_deleted.where(id: students[0].id).first.restore_recursively

    # restore to the same as before
    expect(Student.where(id: students[0].id).exists?).to be_truthy
    expect(Parent.where(id: parent[0].id).exists?).to be_truthy
    expect(StudentList.where(id: student_lists[0].id).exists?).to be_truthy
    expect(StudentsParent.where(id: studentsparent[0].id).exists?).to be_truthy
    expect(Relationship.where(id: relationships[0].id).exists?).to be_truthy
    expect(List.where(id: lists[0].id).exists?).to be_truthy
    expect(Alumni.exists?).to be_falsey
  end

  it 'should soft delete student\'s parent when student are destroy' do
    expect(Student.where(id: students[0].id).exists?).to be_truthy
    expect(Parent.where(id: parent[0].id).exists?).to be_truthy
    expect(StudentList.where(id: student_lists[0].id).exists?).to be_truthy
    expect(StudentsParent.where(id: studentsparent[0].id).exists?).to be_truthy
    expect(Relationship.where(id: relationships[0].id).exists?).to be_truthy
    expect(List.where(id: lists[0].id).exists?).to be_truthy
    expect(Alumni.exists?).to be_falsey

    students[0].destroy

    # do nothing for alumni
    expect(Alumni.exists?).to be_falsey

    # soft delete student
    expect(Student.where(id: students[0].id).exists?).to be_falsey
    expect(Student.with_deleted.where(id: students[0].id).exists?).to be_truthy

    # soft delete parent when destroy their last student
    expect(Parent.where(id: parent[0].id).exists?).to be_falsey
    expect(Parent.with_deleted.where(id: parent[0].id).exists?).to be_truthy

    # soft delete student_lists
    expect(StudentList.where(id: student_lists[0].id).exists?).to be_falsey
    expect(StudentList.with_deleted.where(id: student_lists[0].id).exists?).to be_truthy

    # soft delete studentsparent
    expect(StudentsParent.where(id: studentsparent[0].id).exists?).to be_falsey
    expect(StudentsParent.with_deleted.where(id: studentsparent[0].id).exists?).to be_truthy

    # do nothing for relationships
    expect(Relationship.where(id: relationships[0].id).exists?).to be_truthy

    # do nothing for lists
    expect(List.where(id: lists[0].id).exists?).to be_truthy
  end

  it 'should restore destroy student' do
    students[0].destroy
    expect(Parent.where(id: parent[0].id).exists?).to be_falsey

    Student.with_deleted.where(id: students[0].id).first.restore_recursively

    # restore to the same as before
    expect(Student.where(id: students[0].id).exists?).to be_truthy
    expect(Parent.where(id: parent[0].id).exists?).to be_truthy
    expect(StudentList.where(id: student_lists[0].id).exists?).to be_truthy
    expect(StudentsParent.where(id: studentsparent[0].id).exists?).to be_truthy
    expect(Relationship.where(id: relationships[0].id).exists?).to be_truthy
    expect(List.where(id: lists[0].id).exists?).to be_truthy
    expect(Alumni.exists?).to be_falsey
  end

  describe 'parent with 2 student' do
    it 'should soft delete student\'s parent when student are graduate' do
      expect(Student.where(id: students[1].id).exists?).to be_truthy
      expect(Student.where(id: students[2].id).exists?).to be_truthy
      expect(Parent.where(id: parent[1].id).exists?).to be_truthy
      expect(StudentList.where(id: student_lists[1].id).exists?).to be_truthy
      expect(StudentList.where(id: student_lists[2].id).exists?).to be_truthy
      expect(StudentsParent.where(id: studentsparent[1].id).exists?).to be_truthy
      expect(StudentsParent.where(id: studentsparent[2].id).exists?).to be_truthy
      expect(Relationship.where(id: relationships[1].id).exists?).to be_truthy
      expect(List.where(id: lists[0].id).exists?).to be_truthy
      expect(Alumni.exists?).to be_falsey

      students[1].graduate

      # create alumni with status = "จบการศึกษา"
      expect(Alumni.where(student_id: students[1].id).exists?).to be_truthy
      expect(Alumni.where(student_id: students[1].id).first.status).to eq "จบการศึกษา"
      ## do nothing for other student
      expect(Alumni.where(student_id: students[2].id).exists?).to be_falsey

      # soft delete student
      expect(Student.where(id: students[1].id).exists?).to be_falsey
      expect(Student.with_deleted.where(id: students[1].id).exists?).to be_truthy
      ## do nothing for other student
      expect(Student.where(id: students[2].id).exists?).to be_truthy

      # do nothing for parent that have one student left
      expect(Parent.where(id: parent[1].id).exists?).to be_truthy

      # soft delete student_lists
      expect(StudentList.where(id: student_lists[1].id).exists?).to be_falsey
      expect(StudentList.with_deleted.where(id: student_lists[1].id).exists?).to be_truthy
      ## do nothing for other student
      expect(StudentList.where(id: student_lists[2].id).exists?).to be_truthy

      # do nothing for studentsparent
      expect(StudentsParent.where(id: studentsparent[1].id).exists?).to be_falsey
      ## do nothing for other student
      expect(StudentsParent.where(id: studentsparent[2].id).exists?).to be_truthy

      # do nothing for relationships
      expect(Relationship.where(id: relationships[1].id).exists?).to be_truthy

      # do nothing for lists
      expect(List.where(id: lists[0].id).exists?).to be_truthy
    end

    it 'should restore graduated student' do
      students[1].graduate
      expect(Student.where(id: students[1].id).exists?).to be_falsey

      Student.with_deleted.where(id: students[1].id).first.restore_recursively

      # restore to the same as before
      expect(Student.where(id: students[1].id).exists?).to be_truthy
      expect(Student.where(id: students[2].id).exists?).to be_truthy
      expect(Parent.where(id: parent[1].id).exists?).to be_truthy
      expect(StudentList.where(id: student_lists[1].id).exists?).to be_truthy
      expect(StudentList.where(id: student_lists[2].id).exists?).to be_truthy
      expect(StudentsParent.where(id: studentsparent[1].id).exists?).to be_truthy
      expect(StudentsParent.where(id: studentsparent[2].id).exists?).to be_truthy
      expect(Relationship.where(id: relationships[1].id).exists?).to be_truthy
      expect(List.where(id: lists[0].id).exists?).to be_truthy
      expect(Alumni.exists?).to be_falsey
    end

    it 'should soft delete student\'s parent when student are resign' do
      expect(Student.where(id: students[1].id).exists?).to be_truthy
      expect(Student.where(id: students[2].id).exists?).to be_truthy
      expect(Parent.where(id: parent[1].id).exists?).to be_truthy
      expect(StudentList.where(id: student_lists[1].id).exists?).to be_truthy
      expect(StudentList.where(id: student_lists[2].id).exists?).to be_truthy
      expect(StudentsParent.where(id: studentsparent[1].id).exists?).to be_truthy
      expect(StudentsParent.where(id: studentsparent[2].id).exists?).to be_truthy
      expect(Relationship.where(id: relationships[1].id).exists?).to be_truthy
      expect(List.where(id: lists[0].id).exists?).to be_truthy
      expect(Alumni.exists?).to be_falsey

      students[1].resign

      # create alumni with status = "ลาออก"
      expect(Alumni.where(student_id: students[1].id).exists?).to be_truthy
      expect(Alumni.where(student_id: students[1].id).first.status).to eq "ลาออก"
      ## do nothing for other student
      expect(Alumni.where(student_id: students[2].id).exists?).to be_falsey

      # soft delete student
      expect(Student.where(id: students[1].id).exists?).to be_falsey
      expect(Student.with_deleted.where(id: students[1].id).exists?).to be_truthy
      ## do nothing for other student
      expect(Student.where(id: students[2].id).exists?).to be_truthy

      # do nothing for parent that have one student left
      expect(Parent.where(id: parent[1].id).exists?).to be_truthy

      # soft delete student_lists
      expect(StudentList.where(id: student_lists[1].id).exists?).to be_falsey
      expect(StudentList.with_deleted.where(id: student_lists[1].id).exists?).to be_truthy
      ## do nothing for other student
      expect(StudentList.where(id: student_lists[2].id).exists?).to be_truthy

      # do nothing for studentsparent
      expect(StudentsParent.where(id: studentsparent[1].id).exists?).to be_falsey
      ## do nothing for other student
      expect(StudentsParent.where(id: studentsparent[2].id).exists?).to be_truthy

      # do nothing for relationships
      expect(Relationship.where(id: relationships[1].id).exists?).to be_truthy

      # do nothing for lists
      expect(List.where(id: lists[0].id).exists?).to be_truthy
    end

    it 'should restore resign student' do
      students[1].resign
      expect(Student.where(id: students[1].id).exists?).to be_falsey

      Student.with_deleted.where(id: students[1].id).first.restore_recursively

      # restore to the same as before
      expect(Student.where(id: students[1].id).exists?).to be_truthy
      expect(Student.where(id: students[2].id).exists?).to be_truthy
      expect(Parent.where(id: parent[1].id).exists?).to be_truthy
      expect(StudentList.where(id: student_lists[1].id).exists?).to be_truthy
      expect(StudentList.where(id: student_lists[2].id).exists?).to be_truthy
      expect(StudentsParent.where(id: studentsparent[1].id).exists?).to be_truthy
      expect(StudentsParent.where(id: studentsparent[2].id).exists?).to be_truthy
      expect(Relationship.where(id: relationships[1].id).exists?).to be_truthy
      expect(List.where(id: lists[0].id).exists?).to be_truthy
      expect(Alumni.exists?).to be_falsey
    end

    it 'should soft delete student\'s parent when student are destroy' do
      expect(Student.where(id: students[1].id).exists?).to be_truthy
      expect(Student.where(id: students[2].id).exists?).to be_truthy
      expect(Parent.where(id: parent[1].id).exists?).to be_truthy
      expect(StudentList.where(id: student_lists[1].id).exists?).to be_truthy
      expect(StudentList.where(id: student_lists[2].id).exists?).to be_truthy
      expect(StudentsParent.where(id: studentsparent[1].id).exists?).to be_truthy
      expect(StudentsParent.where(id: studentsparent[2].id).exists?).to be_truthy
      expect(Relationship.where(id: relationships[1].id).exists?).to be_truthy
      expect(List.where(id: lists[0].id).exists?).to be_truthy
      expect(Alumni.exists?).to be_falsey

      students[1].destroy
      expect(Student.where(id: students[1].id).exists?).to be_falsey

      # do nothing for alumni
      expect(Alumni.where(student_id: students[1].id).exists?).to be_falsey
      expect(Alumni.where(student_id: students[2].id).exists?).to be_falsey

      # soft delete student
      expect(Student.where(id: students[1].id).exists?).to be_falsey
      expect(Student.with_deleted.where(id: students[1].id).exists?).to be_truthy
      ## do nothing for other student
      expect(Student.where(id: students[2].id).exists?).to be_truthy

      # soft delete parent when destroy their last student
      expect(Parent.where(id: parent[1].id).exists?).to be_truthy

      # soft delete student_lists
      expect(StudentList.where(id: student_lists[1].id).exists?).to be_falsey
      expect(StudentList.with_deleted.where(id: student_lists[1].id).exists?).to be_truthy
      ## do nothing for other student
      expect(StudentList.where(id: student_lists[2].id).exists?).to be_truthy

      # do nothing for studentsparent
      expect(StudentsParent.where(id: studentsparent[1].id).exists?).to be_falsey
      expect(StudentsParent.where(id: studentsparent[2].id).exists?).to be_truthy

      # do nothing for relationships
      expect(Relationship.where(id: relationships[1].id).exists?).to be_truthy

      # do nothing for lists
      expect(List.where(id: lists[0].id).exists?).to be_truthy
    end

    it 'should restore destroy student' do
      students[1].destroy
      expect(Student.where(id: students[1].id).exists?).to be_falsey

      Student.with_deleted.where(id: students[1].id).first.restore_recursively

      # restore to the same as before
      expect(Student.where(id: students[1].id).exists?).to be_truthy
      expect(Student.where(id: students[2].id).exists?).to be_truthy
      expect(Parent.where(id: parent[1].id).exists?).to be_truthy
      expect(StudentList.where(id: student_lists[1].id).exists?).to be_truthy
      expect(StudentList.where(id: student_lists[2].id).exists?).to be_truthy
      expect(StudentsParent.where(id: studentsparent[1].id).exists?).to be_truthy
      expect(StudentsParent.where(id: studentsparent[2].id).exists?).to be_truthy
      expect(Relationship.where(id: relationships[1].id).exists?).to be_truthy
      expect(List.where(id: lists[0].id).exists?).to be_truthy
      expect(Alumni.exists?).to be_falsey
    end
  end

end
