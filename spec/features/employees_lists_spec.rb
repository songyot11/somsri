describe 'Employee Lists', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }

  let(:employees) do
    [
      employee1 = Employee.make!({
        school_id: school.id,
        first_name: "สมศรี",
        last_name: "เป็นชื่อแอพ",
        prefix: "นาง",
        sex: 1,
        account_number: "5-234-34532-2342",
        salary: 50000
      }),
      employee2 = Employee.make!({
        school_id: school.id,
        first_name: "สมจิตร",
        last_name: "เป็นนักมวย",
        prefix: "นาย",
        sex: 1,
        account_number: "5-234-34532-2342",
        salary: 50000
      })
    ]
  end

  let(:payrolls) do
    [
      Payroll.make!({
        employee_id: employees[0].id,
        salary: 50000,
        tax: 100,
        advance_payment: 2000,
        allowance: 3000,
        created_at: DateTime.now
      }),

      Payroll.make!({
        employee_id: employees[1].id,
        salary: 50000,
        tax: 1000,
        position_allowance: 10000,
        fee_etc: 200,
        created_at: DateTime.now
      })
    ]
  end

  before do
    payrolls
  end

  it 'should goto employees list when click employee button' do
    visit "/#/"
    find('.main-menu-image.employees').click
    sleep(1)
    expect(page).to have_css('div.employees-list')
  end

  it 'should see employees list' do
    visit "/#/employees"
    expect(page).to have_content 'นาง สมศรี เป็นชื่อแอพ เงินเดือน : 50000 บาท เงินหัก : 2100 บาท เงินเพิ่ม : 3000 บาท'
    expect(page).to have_content 'นาย สมจิตร เป็นนักมวย เงินเดือน : 50000 บาท เงินหัก : 1200 บาท เงินเพิ่ม : 10000 บาท'
  end
end
