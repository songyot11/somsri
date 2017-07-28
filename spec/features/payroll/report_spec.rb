describe 'Payroll Report', js: true do
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
      employee_type: "ลูกจ้างประจำ",
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
      employee_type: "ลูกจ้างชั่วคราว",
      account_number: "5-234-34532-2342",
      salary: 20000
    }
  )}
  let(:employee3) {Employee.make!(
    {
      school_id: school2.id,
      first_name: "Knight",
      middle_name: "King",
      last_name: "Harabas",
      prefix: "Mr",
      first_name_thai: "คิง",
      last_name_thai: "ฮาราบาส",
      prefix_thai: "นาย",
      sex: 1,
      employee_type: "ลูกจ้างรายวัน",
      account_number: "5-234-34532-0000",
      salary: 20000
    }
  )}

  let(:employee4) {Employee.make!(
    {
      school_id: school.id,
      first_name_thai: "ดี",
      last_name_thai: "เอ็ม",
      prefix_thai: "พี",
      sex: 1,
      account_number: "5-234-34532-xxxx",
      employee_type: "ลูกจ้างรายวัน",
      salary: 20
    }
  )}

  let(:payrolls) do
    [
      Payroll.make!({employee_id: employee1.id, salary: 1_000_000,
                            effective_date: DateTime.new(2016, 12, 1)}),
      Payroll.make!({employee_id: employee2.id, salary: 1_000_000,
                            effective_date: DateTime.new(2016, 12, 1)}),
      Payroll.make!({employee_id: employee1.id, salary: 50_000,
                            effective_date: DateTime.new(2016, 11, 1)}),
      Payroll.make!({employee_id: employee2.id, salary: 50_000,
                            effective_date: DateTime.new(2016, 11, 1)}),
      Payroll.make!({employee_id: employee3.id, salary: 20_000,
                            effective_date: DateTime.new(2016, 11, 1)}),
      Payroll.make!({employee_id: employee4.id, salary: 1_000_000,
                            effective_date: DateTime.new(2016, 12, 1)}),
    ]
  end

  let(:taxrates) do
    [
      Taxrate.make!({order_id: "1", income: "5000000", tax: "0.35"}),
      Taxrate.make!({order_id: "2", income: "2000000", tax: "0.30"}),
      Taxrate.make!({order_id: "3", income: "1000000", tax: "0.25"}),
      Taxrate.make!({order_id: "4", income: "750000", tax: "0.20"}),
      Taxrate.make!({order_id: "5", income: "500000", tax: "0.15"}),
      Taxrate.make!({order_id: "6", income: "300000", tax: "0.10"}),
      Taxrate.make!({order_id: "7", income: "150000", tax: "0.05"})
    ]
  end

  before do
    user.add_role :admin
    taxrates
    payrolls
    login_as(user, scope: :user)
  end

  it 'should display social_insurance_pdf button' do
    visit "/somsri_payroll#/report"
    sleep(1)
    find('#print-report-btn').click
    sleep(1)
    eventually { expect(page).to have_content /พิมพ์สรุปรายการ/i }
    eventually { expect(page).to have_content /พิมพ์สลิปเงินเดือนทุกคน/i }
    eventually { expect(page).to have_content /พิมพ์ประกันสังคม/i }
  end

  it 'should see header table' do
    visit "/somsri_payroll#/report"
    eventually { expect(page).to have_content 'รหัส ชื่อ เลขบัญชี เงินเดือน เงินเพิ่ม เงินหัก เงินเดือนสุทธิ' }
    eventually { expect(page).to have_content 'รวมทั้งหมด' }
  end

  it 'should see month latest' do
    visit "/somsri_payroll#/report"
    sleep(1)
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 1,000,000.00' }
    eventually { expect(page).to have_content 'สมจิตร เป็นนักมวย 5-234-34532-2342 1,000,000.00 0.00 0.00 1,000,000.00' }
    eventually { expect(page).to have_content 'พี ดี เอ็ม 5-234-34532-xxxx 1,000,000.00 0.00 0.00 1,000,000.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 3,000,000.00 0.00 0.00 3,000,000.00' }
  end

  it 'should see month list' do
    visit "/somsri_payroll#/report"
    sleep(1)
    find('#month-list').click
    sleep(1)
    eventually { expect(page).to have_content '1 ธันวาคม 2559 1 พฤศจิกายน 2559' }
  end

  it 'should switch month' do
    visit "/somsri_payroll#/report"
    find('#month-list').click
    sleep(1)
    click_on("พฤศจิกายน 2559")
    sleep(1)

    eventually { expect(page).to have_content 'รหัส ชื่อ เลขบัญชี เงินเดือน เงินเพิ่ม เงินหัก เงินเดือนสุทธิ' }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 50,000.00 0.00 0.00 50,000.00' }
    eventually { expect(page).to have_content 'สมจิตร เป็นนักมวย 5-234-34532-2342 50,000.00 0.00 0.00 50,000.00' }
    eventually { expect(page).to have_content 'นาย คิง ฮาราบาส 5-234-34532-0000 20,000.00 0.00 0.00 20,000.00' }

    eventually { expect(page).not_to have_content 'พี ดี เอ็ม' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 120,000.00 0.00 0.00 120,000.00' }
  end

  describe 'employee link' do
    it 'go to employee detail and display payroll of the same month as report screen' do
      visit "/somsri_payroll#/report"
      find('#month-list').click
      sleep(1)
      click_on("1 พฤศจิกายน 2559")
      sleep(1)

      click_link "สมศรี เป็นชื่อแอพ"
      sleep(1)
      click_link "เงินเดือน"
      sleep(1)
      eventually { expect(page).to have_content '1 พฤศจิกายน 2559' }
      expect(find_field('ค่าแรง / เงินเดือนปัจจุบัน', disabled: true).value).to eq '50000'
    end
  end

  it 'should see fliter button with actived status' do
    visit "/somsri_payroll#/report"
    sleep(1)
    expect(page).to have_selector('.active.employee-type[ng-model="report.employeeTypeMode.normal"]')
    expect(page).to have_selector('.active.employee-type[ng-model="report.employeeTypeMode.temporary"]')
    expect(page).to have_selector('.active.employee-type[ng-model="report.employeeTypeMode.probationary"]')
    expect(page).to have_selector('.active.employee-type[ng-model="report.employeeTypeMode.daily"]')

    expect(page).to have_content 'พี ดี เอ็ม'
    expect(page).to have_content 'นาย สมจิตร เป็นนักมวย'
    expect(page).to have_content 'นาง สมศรี เป็นชื่อแอพ'
  end

  it 'can fliter button data' do
    visit "/somsri_payroll#/report"
    sleep(1)
    find('.active.employee-type[ng-model="report.employeeTypeMode.normal"]').click
    find('.active.employee-type[ng-model="report.employeeTypeMode.probationary"]').click
    sleep(1)

    expect(page).to_not have_selector('.active.employee-type[ng-model="report.employeeTypeMode.normal"]')
    expect(page).to have_selector('.active.employee-type[ng-model="report.employeeTypeMode.temporary"]')
    expect(page).to_not have_selector('.active.employee-type[ng-model="report.employeeTypeMode.probationary"]')
    expect(page).to have_selector('.active.employee-type[ng-model="report.employeeTypeMode.daily"]')

    expect(page).to have_content 'พี ดี เอ็ม'
    expect(page).to have_content 'นาย สมจิตร เป็นนักมวย'
    expect(page).to_not have_content 'นาง สมศรี เป็นชื่อแอพ'
  end

  it 'should not see datas when disable all button' do
    visit "/somsri_payroll#/report"
    sleep(1)
    find('.active.employee-type[ng-model="report.employeeTypeMode.normal"]').click
    find('.active.employee-type[ng-model="report.employeeTypeMode.probationary"]').click
    find('.active.employee-type[ng-model="report.employeeTypeMode.daily"]').click
    find('.active.employee-type[ng-model="report.employeeTypeMode.temporary"]').click
    sleep(1)

    expect(page).to_not have_selector('.active.employee-type[ng-model="report.employeeTypeMode.normal"]')
    expect(page).to_not have_selector('.active.employee-type[ng-model="report.employeeTypeMode.temporary"]')
    expect(page).to_not have_selector('.active.employee-type[ng-model="report.employeeTypeMode.probationary"]')
    expect(page).to_not have_selector('.active.employee-type[ng-model="report.employeeTypeMode.daily"]')

    expect(page).to_not have_content 'พี ดี เอ็ม'
    expect(page).to_not have_content 'นาย สมจิตร เป็นนักมวย'
    expect(page).to_not have_content 'นาง สมศรี เป็นชื่อแอพ'
  end
end
