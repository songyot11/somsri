describe StudentsController do
  render_views
  let(:school)do
    School.make!
  end

  let(:parent) { Parent.make! }

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

  let(:student) { students.first }

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
    describe '#index' do
      it "should show all student" do
        get :index, format: :json, params: { grade_select: 'all' , class_select: 'all' }, format: :json

        expect(response.body).to have_content "one"
        expect(response.body).to have_content "two"
        expect(response.body).to have_content "three"
        expect(response.body).to have_content "four"
        expect(response.body).to have_content "five"
      end

      it "should show all student on print list" do
        get :index, params: { grade_select: 'all' , class_select: 'all', for_print: true }, format: :json

        expect(response.body).to have_content "one"
        expect(response.body).to have_content "two"
        expect(response.body).to have_content "three"
        expect(response.body).to have_content "four"
        expect(response.body).to have_content "five"
      end

      it 'should show only grade that selected' do
        get :index, format: :json, params: { grade_select: 'Preschool' }

        expect(response.body).to have_content "one"
        expect(response.body).to have_content "five"
      end

      it 'should show only grade that selected on print list' do
        get :index , params: { grade_select: 'Preschool', for_print: true  }, format: :json

        expect(response.body).to have_content "one"
        expect(response.body).to have_content "five"
      end

      it 'should show only classroom that selected' do
        get :index, format: :json, params: { class_select: '4A' }

        expect(response.body).to have_content "four"
      end

      it 'should show only classroom that selected on print list' do
        get :index , params: { class_select: '4A', for_print: true }, format: :json

        expect(response.body).to have_content "four"
      end

      it 'should show both grade and classroom that selected' do
        get :index, format: :json, params: { grade_select: 'Kindergarten 1' , class_select: '2A' }

        expect(response.body).to have_content "two"
      end

      it 'should show both grade and classroom that selected on print list' do
        get :index , params: { grade_select: 'Kindergarten 1' , class_select: '2A', for_print: true }, format: :json

        expect(response.body).to have_content "two"
      end
    end

    describe '#index' do
      it 'redirect to #index' do
        params = Student.make.attributes
        params.delete 'id'
        expect do
          post :create, params: { student: params }
        end.to change{ Student.count }.by 1
        expect(response).to redirect_to students_path
      end
    end

    describe '#update' do
      it 'can update student' do
        new_name = 'new_one'
        patch :update, params: { id: student.id, student: { full_name: new_name} }
        expect(student.reload.first_name).to eq new_name
      end

      it 'redirect to #index' do
          new_name = 'new_one'
          patch :update, params: { id: student.id, student: { full_name: new_name} }
          expect(response).to redirect_to students_path
      end

      it 'can handle full name' do
        new_name = 'one two'
        patch :update, params: { id: student.id, student: { full_name: new_name} }
        expect(student.reload.first_name).to eq 'one'
        expect(student.last_name).to eq 'two'
      end

      it 'can add parent' do
        expect do
          patch :update, params: {
            id: student.id,
            student: { full_name: student.full_name },
            parent: ['sn'],
            relationship: ['1']
          }
          expect(assigns['parents'].length).to eq 1
        end.to change{ Parent.count }.by 1
      end

      it 'can add assign existing parent' do
        parent # create new parent

        expect do
          patch :update, params: {
            id: student.id,
            student: { full_name: student.full_name },
            parent: [parent.id],
            relationship: ['1']
          }
          expect(student.reload.parents.first).to eq parent
        end.to change{ Parent.count }.by 0
      end
    end
  end
end
