describe StudentsController do

  let(:school)do
    School.make!
  end

  let(:employees) do
    [
      Employee.make!({ school_id: school.id, pin: "1111" }),
      Employee.make!({ school_id: school.id, pin: "2222" })
    ]
  end

  let(:students) do
    [
      Student.make!(school_id: school.id, student_number: 101, classroom_number: 1),
      Student.make!(school_id: school.id, student_number: 102, classroom_number: 2),
      Student.make!(school_id: school.id, student_number: 103, classroom_number: 3),
      Student.make!(school_id: school.id, student_number: 104, classroom_number: 1),
      Student.make!(school_id: school.id, student_number: 105, classroom_number: 2)
    ]
  end

  let(:lists) do
    [
      List.make!({ name: "ม. 1/1", category: "roll_call"}),
      List.make!({ name: "ม. 1/2", category: "roll_call"})
    ]
  end

  let(:student_list) do
    [
      StudentList.make!({ student_id: students[0].id, list_id: lists[0].id }),
      StudentList.make!({ student_id: students[1].id, list_id: lists[0].id }),
      StudentList.make!({ student_id: students[2].id, list_id: lists[0].id }),
      StudentList.make!({ student_id: students[3].id, list_id: lists[1].id }),
      StudentList.make!({ student_id: students[4].id, list_id: lists[1].id }),
    ]
  end

  let(:teacher_attendance_lists) do
    [
      TeacherAttendanceList.make!({ list_id: lists[0].id, employee_id: employees[0].id}),
      TeacherAttendanceList.make!({ list_id: lists[1].id, employee_id: employees[1].id})
    ]
  end

  before :each do
    students
    employees
    student_list
    teacher_attendance_lists
  end

  describe "get: get_roll_calls /get_roll_calls/" do
    it "should return student in user's roll call using PIN" do
      student_list
      get 'get_roll_calls', params: { pin: employees[0]['pin'] }
      data = JSON.parse(response.body)
      expect(data.size).to eq(3)
      found_data = 0
      data.each do |d|
        students.each do |s|
          if d["code"] == s.code
            found_data += 1
          end
        end
      end
      expect(found_data).to eq(3)
    end
  end


end
