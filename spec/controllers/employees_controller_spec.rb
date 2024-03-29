describe EmployeesController do
  let(:admin) do
    user = User.make!
    user.add_role :admin
    user
  end
  let(:employee) { Employee.make! }
  let(:grade) do
    Grade.make!({
      name: "มัธยมศึกษาปีที่ 1"
    })
  end
  let(:classroom) do
    Classroom.make!({
      name: "1/1",
      grade_id: grade.id
    })
  end

  before :each do
    classroom
    sign_in admin
  end

  describe '#create' do
    it 'can create employee' do
      new_employee = Employee.make
      expect do
        post :create, params: { employee: new_employee.attributes.merge(password: 'password') }
      end.to change{ Employee.count }.by 1

      created_employee = Employee.last
      expect(created_employee.first_name).to eq new_employee.first_name
      expect(created_employee.last_name).to eq new_employee.last_name
    end
  end

  describe '#update' do
    it 'can update grade and classroom' do
      patch :update, params: {
        id: employee.id,
        employee: {
          classroom_id: classroom.id,
          grade_id: grade.id
        }
      }

      expect(employee.reload.grade).to eq grade
      expect(employee.classroom).to eq classroom
    end
  end
end
