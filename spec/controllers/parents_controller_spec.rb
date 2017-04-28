describe ParentsController do
  render_views
  let(:students) do
    [
      Student.make!(first_name: 'one' , student_number: 101, classroom_number: 1 , classroom: "1A" , grade_id: 1),
      Student.make!(first_name: 'two', student_number: 102, classroom_number: 2 , classroom: "2A" , grade_id: 2),
      Student.make!(first_name: 'three', student_number: 103, classroom_number: 3 , classroom: "3A" , grade_id: 3),
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

  let(:parents) do
    [
      Parent.make!({id: '1' , full_name: 'ฉันเป็น สุภาพบุรุษนะครับ'}),
      Parent.make!({id: '2' , full_name: 'ฉันเป็น ผู้ปกครอง'}),
      Parent.make!({id: '3' , full_name: 'ฉันเป็น สุภาพสตรีค๊ะ'})
    ]
  end

  let(:studentsparent) do
    [
      StudentsParent.make!({id: '1' , student_id: students[0].id , parent_id: parents[0].id}),
      StudentsParent.make!({id: '2' , student_id: students[1].id , parent_id: parents[1].id}),
      StudentsParent.make!({id: '3' , student_id: students[2].id , parent_id: parents[2].id})
    ]
  end

  let(:admin) do
    user = User.make!
    user.add_role :admin
    user
  end

  before :each do
    grades
    students
    parents
    studentsparent
    sign_in admin
  end

  describe 'parents' do
    it 'should show all parent' do
      get :index , class_select: 'all' ,  grade_select: 'all'

      expect(response.body).to have_content("ฉันเป็น สุภาพบุรุษนะครับ")
      expect(response.body).to have_content("ฉันเป็น ผู้ปกครอง")
      expect(response.body).to have_content("ฉันเป็น สุภาพสตรีค๊ะ")
    end

    it 'should show only class that selected' do
      get :index , class_select: '1A' , grade_select: 'all'

      expect(response.body).to have_content("ฉันเป็น สุภาพบุรุษนะครับ")
    end

    it 'should show only grade that selected' do
      get :index , class_select: 'all' , grade_select: 'Kindergarten 1'

      expect(response.body).to have_content("ฉันเป็น ผู้ปกครอง")
    end

    it 'should show both grade and class that selected' do
      get :index , class_select: '3A' , grade_select: 'Kindergarten 2'

      expect(response.body).to have_content("ฉันเป็น สุภาพสตรีค๊ะ")
    end

  end
end
