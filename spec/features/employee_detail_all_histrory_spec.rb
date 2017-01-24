describe 'Employee Details History Modal', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }

  let(:user) { User.make!({ school_id: school.id }) }

  let(:employee) {
    Employee.make!({
      school_id: school.id,
      first_name: "Somsri",
      middle_name: "Is",
      last_name: "Appname",
      prefix: "Mrs.",
      first_name_thai: "สมศรี",
      last_name_thai: "เป็นชื่อแอพ",
      prefix_thai: "นาง",
      salary: 50_000
    })
  }
  let(:payrolls) do
    [
      Payroll.make!({
        employee_id: employee.id,
        salary: 50_000,
        bonus: 15_000,
        tax: 750,
        effective_date: DateTime.new(2017, 1, 1)
      }),
      Payroll.make!({
        employee_id: employee.id,
        salary: 50_000,
        bonus: 15_000,
        tax: 750,
        effective_date: DateTime.new(2017, 2, 1)
      }),
      Payroll.make!({
        employee_id: employee.id,
        salary: 50_000,
        bonus: 15_000,
        tax: 750,
        effective_date: DateTime.new(2017, 3, 1)
      }),
      Payroll.make!({
        employee_id: employee.id,
        salary: 50_000,
        bonus: 15_000,
        tax: 750,
        effective_date: DateTime.new(2017, 4, 1)
      }),
      Payroll.make!({
        employee_id: employee.id,
        salary: 50_000,
        bonus: 15_000,
        tax: 750,
        effective_date: DateTime.new(2017, 5, 1)
      }),
    ]
  end

  before :each do
    payrolls
    login_as(user, scope: :user)
  end

  it 'should see view history button' do
    visit "/#/employees/#{employee.id}"

    expect(page).to have_content('ประวัติเงินเดือน')
  end

  it 'should see payroll when click history button' do
    visit "/#/employees/#{employee.id}"
    click_button('ประวัติเงินเดือน')
    sleep(1)
    sleep(1)
    expect(page).to have_content('ประวัติเงินเดือน เดือน เงินเดือน รายการได้ รายการหัก')
    expect(page).to have_content('พฤษภาคม 2560 50,000.00 15,000.00 750.00')
    expect(page).to have_content('เมษายน 2560 50,000.00 15,000.00 750.00')
    expect(page).to have_content('มีนาคม 2560 50,000.00 15,000.00 750.00')
    expect(page).to have_content('กุมภาพันธ์ 2560 50,000.00 15,000.00 750.00')
    expect(page).to have_content('มกราคม 2560 50,000.00 15,000.00 750.00')
    expect(page).to have_content('ปิด')
  end

end
