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
        advance_payment: 2000,
        closed: true,
        effective_date: DateTime.new(2016, 11, 1),
        allowance: 3000
      }),

      Payroll.make!({
        employee_id: employees[1].id,
        salary: 50000,
        position_allowance: 10000,
        closed: true,
        effective_date: DateTime.new(2016, 11, 1),
        fee_etc: 200
      }),

      Payroll.make!({
        employee_id: employees[2].id,
        salary: 2000,
        position_allowance: 1000,
        closed: true,
        effective_date: DateTime.new(2016, 11, 1),
        fee_etc: 20
      }),

      Payroll.make!({
        employee_id: employees[3].id,
        salary: 0,
        closed: true,
        effective_date: DateTime.new(2016, 11, 1),
        tax: 0
      })
    ]
  end

  before do |example|
    unless example.metadata[:skip_before]
      user.add_role :admin
      payrolls
      login_as(user, scope: :user)
    end
  end

  it 'should see employees list' do
    visit "/somsri_payroll#/employees"
    sleep(1)
    expect(page).to have_content 'นาง สมศรี เป็นชื่อแอพ เงินเดือน 50000 บาท เงินเพิ่ม 3000 บาท เงินหัก 2000 บาท'
    expect(page).to have_content 'นาย สมจิตร เป็นนักมวย เงินเดือน 50000 บาท เงินเพิ่ม 10000 บาท เงินหัก 200 บาท'
    expect(page).to have_content 'นาย สมคิด จิตใจดี เงินเดือน 0 บาท เงินเพิ่ม 0 บาท เงินหัก 0 บาท'
  end

  it 'should display only employee in user\'s school' do
    visit "/somsri_payroll#/employees"
    expect(page).not_to have_content "Harabas"
  end

  it 'can switch display mode' do
    visit "/somsri_payroll#/employees"
    find('.fa-list-ul').click()
    expect(page).to have_content 'นาง สมศรี เป็นชื่อแอพ 50000 บาท 3000 บาท 2000 บาท'
    expect(page).to have_content 'นาย สมจิตร เป็นนักมวย 50000 บาท 10000 บาท 200 บาท'
    expect(page).to have_content 'นาย สมคิด จิตใจดี 0 บาท 0 บาท 0 บาท'
  end

  it 'should see employees list' do
    visit "/somsri_payroll#/employees"
    sleep(1)
    expect(page).to have_content 'นาง สมศรี เป็นชื่อแอพ เงินเดือน 50000 บาท เงินเพิ่ม 3000 บาท เงินหัก 2000 บาท'
    expect(page).to have_content 'นาย สมจิตร เป็นนักมวย เงินเดือน 50000 บาท เงินเพิ่ม 10000 บาท เงินหัก 200 บาท'
    expect(page).to have_content 'นาย สมคิด จิตใจดี เงินเดือน 0 บาท เงินเพิ่ม 0 บาท เงินหัก 0 บาท'
  end

  it 'should create employees with payroll' do
    visit "/somsri_payroll#/employees"
    sleep(1)
    click_on("+ เพิ่มพนักงานใหม่")
    sleep(1)
    page.fill_in 'นามสกุล', :with => 'โอชา'
    page.fill_in 'ชื่อ', :with => 'โบๆ'
    sleep(1)
    click_button('บันทึก')
    sleep(1)
    new_employee = Employee.where(first_name_thai: 'โบๆ', last_name_thai: 'โอชา').first
    visit "/somsri_payroll#/employees/#{new_employee.id}"
    sleep(1)
    expect(page).to have_content 'เงินเดือน'
    click_link('เงินเดือน')
    sleep(1)
    eventually { expect(find_field('ค่าแรง / เงินเดือนปัจจุบัน').value).to eq '0' }
  end
end
