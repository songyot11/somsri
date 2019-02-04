describe 'create employee', js: true do
  let(:school) {school = School.make!({ name: "Suankularb" })}
  let(:user) do
    user = User.make!({ school_id: school.id })
    user.add_role :admin
    user
  end

  before do
    login_as(user, scope: :user)
  end

  it 'can create employee' do
    new_employee = Employee.make

    visit "/somsri_payroll#/employees"
    sleep(1)
    click_link 'เพิ่มพนักงานใหม่'
    fill_in 'ชื่อ', with: new_employee.first_name_thai
    fill_in 'นามสกุล', with: new_employee.last_name_thai
    fill_in 'First Name', with: new_employee.first_name
    fill_in 'Surname', with: new_employee.last_name

    expect do
      click_button 'บันทึก'
      sleep(1)
    end.to change{ Employee.count }.by 1

    visit "/somsri_payroll#/employees"
    sleep(1)
    eventually { expect(page).to have_text(new_employee.first_name_thai) }
  end
end
