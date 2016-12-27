describe 'Employee Lists', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:school2) { School.make!({ name: "โรงเรียนแห่งหนึ่งสอง" }) }

  let(:user) { User.make!({ school_id: school.id }) }

  let(:employees) do
    [
      employee1 = Employee.make!({
        school_id: school.id,
        first_name: "Somsri",
        middle_name: "Is",
        last_name: "Appname",
        prefix: "Mrs.",
        first_name_thai: "สมศรี",
        last_name_thai: "เป็นชื่อแอพ",
        prefix_thai: "นาง",
        salary: 50000
      }),
      employee2 = Employee.make!({
        school_id: school.id,
        first_name: "Somchit",
        middle_name: "Is",
        last_name: "Boxing",
        prefix: "Mr",
        first_name_thai: "สมจิตร",
        last_name_thai: "เป็นนักมวย",
        prefix_thai: "นาย",
        salary: 20000
      }),
      Employee.make!({
        school_id: school2.id,
        first_name: "Knight",
        middle_name: "King",
        last_name: "Harabas",
        prefix: "Mr",
        first_name_thai: "คิง",
        last_name_thai: "ฮาราบาส",
        prefix_thai: "นาย",
        salary: 2000
      }),
      Employee.make!({
        school_id: school.id,
        first_name: "Somkid",
        middle_name: "Jid",
        last_name: "Jaidee",
        prefix: "Mr",
        first_name_thai: "สมคิด",
        last_name_thai: "จิตใจดี",
        prefix_thai: "นาย",
        salary: 2000
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
      }),

      Payroll.make!({
        employee_id: employees[2].id,
        salary: 2000,
        tax: 100,
        position_allowance: 1000,
        fee_etc: 20,
        created_at: DateTime.now
      }),
      
      Payroll.make!({
        employee_id: employees[3].id,
        salary: 0,
        tax: 0,
        created_at: DateTime.now.next_month(1)
      })
    ]
  end

  before do
    payrolls
    login_as(user, scope: :user)
  end

  it 'should goto employees list when click employee button' do
    visit "/#/"
    find('.main-menu-image.employees').click
    sleep(1)
    expect(page).to have_css('div.employees-list')
  end

  it 'should see employees list' do
    visit "/#/employees"
    sleep(1)
    expect(page).to have_content 'นาง สมศรี เป็นชื่อแอพ เงินเดือน : 50000 บาท เงินหัก : 2100 บาท เงินเพิ่ม : 3000 บาท'
    expect(page).to have_content 'นาย สมจิตร เป็นนักมวย เงินเดือน : 50000 บาท เงินหัก : 1200 บาท เงินเพิ่ม : 10000 บาท'
    expect(page).to have_content 'นาย สมคิด จิตใจดี เงินเดือน : 0 บาท เงินหัก : 0 บาท เงินเพิ่ม : 0 บาท'
  end

  it 'should display only employee in user\'s school' do
    visit "/#/employees"
    expect(page).not_to have_content "Harabas"
  end
end
