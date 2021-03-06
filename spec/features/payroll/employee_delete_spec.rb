describe 'Employee delete', js: true do
  let(:school) {school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" })}
  let(:school2) {School.make!({ name: "โรงเรียนแห่ง2" })}
  let(:user) { User.make!({ school_id: school.id }) }
  let(:employee1) {employee1 = Employee.make!(
    {
      school_id: school.id,
      first_name: "Somsri",
      middle_name: "Is",
      last_name: "Appname",
      prefix: "Mrs.",
      first_name_thai: "สมศรี",
      last_name_thai: "เป็นชื่อแอพ",
      prefix_thai: "นาง",
      sex: 1,
      account_number: "5-234-34532-2342",
      salary: 50000
    }
  )}
  let(:employee2) {employee2 = Employee.make!(
    {
      school_id: school.id,
      first_name: "Somchit",
      middle_name: "Is",
      last_name: "Boxing",
      prefix: "Mr",
      first_name_thai: "สมจิตร",
      last_name_thai: "เป็นนักมวย",
      prefix_thai: "นาย",
      sex: 1,
      account_number: "5-234-34532-2342",
      salary: 20000
    }
  )}

  let(:payrolls) do
    [

      Payroll.make!({employee_id: employee1.id, salary: 50_000, tax: 100,
                            effective_date: DateTime.new(2016, 11, 1), closed: true }),
      Payroll.make!({employee_id: employee2.id, salary: 50_000, tax: 100,
                            effective_date: DateTime.new(2016, 12, 1), closed: true }),
      Payroll.make!({employee_id: employee1.id, salary: 40_000, tax: 100,
                            effective_date: DateTime.new(2016, 12, 1), closed: true })
    ]
  end

  before do
    user.add_role :admin
    employee1
    payrolls
    login_as(user, scope: :user)
  end

  it 'should diplay confirmation modal when click delete button ' do
    visit "/somsri_payroll#/employees/#{employee1.id}"
    sleep(1)
    click_button("ลบ")
    sleep(1)
    eventually { expect(page).to have_content("คุณต้องการนำข้อมูลพนักงานออกหรือไม่?") }
  end

  describe 'when confirmed modal with employee not belong to payroll' do
    before do
      visit "/somsri_payroll#/employees/#{employee1.id}"
      click_button("ลบ")
      sleep(1)
      click_button("ตกลง")
      sleep(1)
      eventually { expect(page).to have_content('นาย สมจิตร เป็นนักมวย') }
      eventually { expect(page).to_not have_content('นาง สมศรี เป็นชื่อแอพ') }
    end

    it 'should have this employee in database' do
      eventually { expect(Employee.count).to eq 1}
    end

    it 'should not display on employee list' do
      visit "/somsri_payroll#/employees"

      eventually { expect(page).to have_selector('.card', count: 1) }
    end

    it 'should not display on employee dropdown' do
      visit "/somsri_payroll#/employees/#{employee2.id}"

      find('#employeeName').click
      sleep(1)

      eventually { expect(page).to have_selector('.dropdown-menu li', count: 0) }
    end

    it 'should not display on report' do
      visit "/somsri_payroll#/report"
      sleep(1)
      eventually { expect(page).to have_selector('.fixed-table-body tbody tr td:nth-child(2) a', text: "นาย สมจิตร เป็นนักมวย") }
      eventually { expect(page).to_not have_selector('.fixed-table-body tbody tr td:nth-child(2) a', text: "นาง สมศรี เป็นชื่อแอพ") }
      eventually { expect(page).to have_selector('.fixed-table-body tbody tr td:nth-child(2) strong', text: "นาง สมศรี เป็นชื่อแอพ") }
    end
  end

  describe 'when confirmed modal with employee belong to payroll' do
    before do
      visit "/somsri_payroll#/employees/#{employee2.id}"
      sleep(1)
      click_button("ลบ")
      sleep(1)
      click_button("ตกลง")
      sleep(1)
    end

    it 'should have this employee in database' do
      eventually { expect(Employee.count).to eq 1}
    end

    it 'should not display on employee list' do
      visit "/somsri_payroll#/employees"

      eventually { expect(page).to have_selector('.card', count: 1) }
    end

    it 'should not display on employee dropdown' do
      visit "/somsri_payroll#/employees/#{employee1.id}"

      find('#employeeName').click
      sleep(1)

      eventually { expect(page).to have_selector('.dropdown-menu li', count: 0) }
    end

    it 'should display on report' do
      visit "/somsri_payroll#/report"
      sleep(1)
      eventually { expect(page).to have_selector('a', text: 'สมศรี') }
      eventually { expect(page).to_not have_selector('a', text: 'สมจิตร') }
    end
  end

end
