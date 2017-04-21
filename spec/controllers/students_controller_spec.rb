describe StudentsController do
  render_views
  let(:school)do
    School.make!
  end

  let(:admin) do
    user = User.make!
    user.add_role :admin
    user
  end

  let(:employees) do
    [
      Employee.make!({ school_id: school.id, pin: "1111" }),
      Employee.make!({ school_id: school.id, pin: "2222" })
    ]
  end

  let(:students) do
    [
      Student.make!(first_name: 'one',school_id: school.id, student_number: 101, classroom_number: 1 , classroom: "1A" , grade_id: 1),
      Student.make!(first_name: 'two' , school_id: school.id, student_number: 102, classroom_number: 2 , classroom: "2A" , grade_id: 2),
      Student.make!(first_name: 'three' , school_id: school.id, student_number: 103, classroom_number: 3 , classroom: "3A" , grade_id: 3),
      Student.make!(first_name: 'four' , school_id: school.id, student_number: 104, classroom_number: 1 , classroom: "4A" , grade_id: 4),
      Student.make!(first_name: 'five' , school_id: school.id, student_number: 105, classroom_number: 2 , classroom: "5A" , grade_id: 1)
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

  let(:grades) do
    [
      Grade.make!({id: '1', name: "Preschool"}),
      Grade.make!({id: '2', name: "Kindergarten 1"}),
      Grade.make!({id: '3', name: "Kindergarten 2"}),
      Grade.make!({id: '4', name: "Kindergarten 3"})
    ]
  end

  before :each do
    students
    employees
    student_list
    teacher_attendance_lists
    grades
    sign_in admin
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

  describe "students" do
    it "should show all student" do
      get :index ,  grade_select: 'all' , class_select: 'all'

      expect(response.body).to have_content "one"
      expect(response.body).to have_content "two"
      expect(response.body).to have_content "three"
      expect(response.body).to have_content "four"
      expect(response.body).to have_content "five"
    end

    it 'should show only grade that selected' do
      get :index , grade_select: 'Preschool'

      expect(response.body).to have_content "one"
      expect(response.body).to have_content "five"
    end

    it 'should show only classroom that selected' do
      get :index , class_select: '4A'

      expect(response.body).to have_content "four"
    end

    it 'should show both grade and classroom that selected' do
      get :index , grade_select: 'Kindergarten 1' , class_select: '2A'

      expect(response.body).to have_content "two"
    end
  end



end
