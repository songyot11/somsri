describe 'Employee Details', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }

  let(:employees) do
    [
      Employee.make!({
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
      Employee.make!({
        school_id: school.id,
        first_name: "Somchit",
        middle_name: "Is",
        last_name: "Boxing",
        prefix: "Mr",
        first_name_thai: "สมจิตร",
        last_name_thai: "เป็นนักมวย",
        prefix_thai: "นาย",
        salary: 20000
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
        created_at: DateTime.now.next_month(1)
      }),

      Payroll.make!({
        employee_id: employees[1].id,
        salary: 20000,
        tax: 1000,
        position_allowance: 10000,
        fee_etc: 200,
        created_at: DateTime.now.next_month(1)
      }),

      Payroll.make!({
        employee_id: employees[0].id,
        salary: 5000,
        tax: 10,
        advance_payment: 200,
        allowance: 300,
        created_at: DateTime.now
      }),

      Payroll.make!({
        employee_id: employees[1].id,
        salary: 2000,
        tax: 100,
        position_allowance: 1000,
        fee_etc: 20,
        created_at: DateTime.now
      })
    ]
  end

  before do
    payrolls
  end

  it 'should goto employee details when click employee' do
    visit "/#/employees"
    sleep(1)
    first('.card').click
    sleep(1)
    expect(page).to have_css('div.employee-details')
  end

  it 'should diplay lastest employee details' do
    visit "/#/employees/#{employees[0].id}"
    sleep(1)
    expect(find_field('ค่าแรง / เงินเดือนปัจจุบัน').value).to eq '50000'
    expect(find_field('ภาษี').value).to eq '100'
    expect(find_field('เบิกล่วงหน้า').value).to eq '2000'
    expect(find_field('ค่ากะ / ค่าเบี้ยเลี้ยง').value).to eq '3000'
    expect(page).to have_content('เงินเดือนสุทธิ 50900')
  end

  it 'should diplay total pay depend on payroll change' do
    visit "/#/employees/#{employees[0].id}"
    sleep(1)
    page.fill_in 'ค่าแรง / เงินเดือนปัจจุบัน', :with => '2000000'
    page.fill_in 'ภาษี', :with => '1000000'
    page.fill_in 'ค่าล่วงเวลา', :with => '500000'
    page.fill_in 'ประกันสังคม', :with => '300000'
    page.fill_in 'ค่าตำแหน่ง', :with => '70000'
    page.fill_in 'เงินสะสมเข้ากองทุน PVF', :with => '40000'
    page.fill_in 'ค่ากะ / ค่าเบี้ยเลี้ยง', :with => '5000'
    page.fill_in 'ขาดงาน', :with => '1000'
    page.fill_in 'เบี้ยขยัน', :with => '500'
    page.fill_in 'โบนัส', :with => '90'
    page.fill_in 'เบิกล่วงหน้า', :with => '30'
    page.fill_in 'รายได้อื่นๆ', :with => '9'
    page.fill_in 'หักอื่นๆ', :with => '2'
    sleep(1)
    expect(page).to have_content('เงินเดือนสุทธิ 1234567')
  end

  it 'should diplay confirmation modal when change detail and click ยกเลิก' do
    visit "/#/employees/#{employees[0].id}"
    sleep(1)
    page.fill_in 'First Name', :with => 'Eve'
    page.fill_in 'โบนัส', :with => 99999999
    sleep(1)
    click_button('ยกเลิก')
    sleep(1)
    expect(page).to have_content("คุณต้องการออกจากหน้านี้โดยไม่บันทึกค่าหรือไม่?")
  end

  it 'should save change and goto employee lists' do
    visit "/#/employees/#{employees[0].id}"
    sleep(1)
    page.fill_in 'ค่าแรง / เงินเดือนปัจจุบัน', :with => '200'
    page.fill_in 'นามสกุล', :with => 'โอชา'
    sleep(1)
    click_button('บันทึก')
    sleep(1)

    employee = Employee.find(employees[0].id)
    payroll = Payroll.find(payrolls[0].id)

    expect(employee.last_name_thai).to eq 'โอชา'
    expect(employee.salary).to eq 200
    expect(payroll.salary).to eq 200
    expect(page).to have_css('div.employees-list')
  end

end
