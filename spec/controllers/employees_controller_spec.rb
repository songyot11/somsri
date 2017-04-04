describe EmployeesController do
  let(:admin) do
    user = User.make!
    user.add_role :admin
    user
  end

  let(:employee) { Employee.make! }

  before :each do
    sign_in admin
  end

  describe '#create' do
    it 'can create employee' do
      new_employee = Employee.make

      expect do
        post :create, params: { employee: new_employee.attributes }
      end.to change{ Employee.count }.by 1

      created_employee = Employee.last
      expect(created_employee.first_name).to eq new_employee.first_name
      expect(created_employee.last_name).to eq new_employee.last_name
    end
  end

  describe '#update' do
    it 'can update grade and classroom' do
      grade = Grade.make!
      patch :update, id: employee.id, employee: {
        classroom: '1/1',
        grade_id: grade.id
      }

      expect(employee.reload.grade).to eq grade
      expect(employee.classroom).to eq '1/1'
    end
  end
end
