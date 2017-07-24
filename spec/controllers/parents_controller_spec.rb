describe ParentsController do
  render_views
  let(:students) do
    [
      Student.make!(
        first_name: 'one',
        student_number: 101,
        classroom_number: 1,
        classroom: "1A",
        grade_id: grades[0].id
      ),
      Student.make!(
        first_name: 'two',
        student_number: 102,
        classroom_number: 2,
        classroom: "2A",
        grade_id: grades[1].id
      ),
      Student.make!(
        first_name: 'three',
        student_number: 103,
        classroom_number: 3,
        classroom: "3A",
        grade_id: grades[2].id
      ),
    ]
  end

  let(:grades) do
    [
      Grade.make!({name: "Preschool"}),
      Grade.make!({name: "Kindergarten 1"}),
      Grade.make!({name: "Kindergarten 2"}),
      Grade.make!({name: "Kindergarten 3"})
    ]
  end

  let(:parents) do
    [
      Parent.make!({full_name: 'ฉันเป็น สุภาพบุรุษนะครับ'}),
      Parent.make!({full_name: 'ฉันเป็น ผู้ปกครอง'}),
      Parent.make!({full_name: 'ฉันเป็น สุภาพสตรีค๊ะ'})
    ]
  end

  let(:studentsparent) do
    [
      StudentsParent.make!({student_id: students[0].id , parent_id: parents[0].id}),
      StudentsParent.make!({student_id: students[1].id , parent_id: parents[1].id}),
      StudentsParent.make!({student_id: students[2].id , parent_id: parents[2].id})
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
      get :index, format: :json , params: { class_select: 'all' ,  grade_select: 'all', offset: 0, limit: 10 }
      
      expect(response.body).to have_content("ฉันเป็น สุภาพบุรุษนะครับ")
      expect(response.body).to have_content("ฉันเป็น ผู้ปกครอง")
      expect(response.body).to have_content("ฉันเป็น สุภาพสตรีค๊ะ")
    end

    it 'should show only class that selected' do
      get :index, format: :json, params: { class_select: '1A' , grade_select: 'all', offset: 0, limit: 10 }

      expect(response.body).to have_content("ฉันเป็น สุภาพบุรุษนะครับ")
    end

    it 'should show only grade that selected' do
      get :index, format: :json, params: { class_select: 'all' , grade_select: 'Kindergarten 1', offset: 0, limit: 10 }

      expect(response.body).to have_content("ฉันเป็น ผู้ปกครอง")
    end

    it 'should show both grade and class that selected' do
      get :index, format: :json, params: { class_select: '3A' , grade_select: 'Kindergarten 2', offset: 0, limit: 10 }

      expect(response.body).to have_content("ฉันเป็น สุภาพสตรีค๊ะ")
    end
  end

  describe '#create' do
    it 'redirect to #index' do
      params = Parent.make.attributes
      params.delete 'id'
      expect do
        post :create, params: { parent: params }
      end.to change{ Parent.count }.by 1
      expect(response).to redirect_to parents_path
    end
  end

  describe '#update' do
    it 'redirect to #index' do
      patch :create, params: { id: parents.first.id, parent: { email: 'new@email.com' } }
      expect(response).to redirect_to parents_path
    end
  end
end
