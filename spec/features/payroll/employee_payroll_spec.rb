describe 'Payroll', js: true do
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
      employee_type: "ลูกจ้างประจำ",
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
      employee_type: "ลูกจ้างชั่วคราว",
      sex: 1,
      account_number: "5-234-34532-2341",
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
      salary: 20
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
      pr1 = Payroll.make!({employee_id: employee1.id, salary: 1_000_000,
                            effective_date: DateTime.new(2016, 12, 1), social_insurance: 750}),
      pr3 = Payroll.make!({employee_id: employee2.id, salary: 1_000_000,
                            effective_date: DateTime.new(2016, 12, 1), social_insurance: 750}),
      pr2 = Payroll.make!({employee_id: employee1.id, salary: 50_000,
                            effective_date: DateTime.new(2016, 11, 1)}),
      pr4 = Payroll.make!({employee_id: employee2.id, salary: 50_000,
                            effective_date: DateTime.new(2016, 11, 1)}),
      pr5 = Payroll.make!({employee_id: employee3.id, salary: 20,
                            effective_date: DateTime.new(2016, 11, 1)}),
      pr6 = Payroll.make!({employee_id: employee4.id, salary: 1_000_000,
                            effective_date: DateTime.new(2016, 12, 1)}),
    ]
  end

  before do
    user.add_role :admin
    payrolls
    login_as(user, scope: :user)
  end
  it 'should see header table' do
    visit "/somsri_payroll#/payroll"
    sleep(1)
    eventually { expect(page).to have_content 'รายการได้รายการหัก' }
    eventually { expect(page).to have_content 'รหัส ชื่อ' }
    eventually { expect(page).to have_content 'เงินเดือน เงินสอนพิเศษ ค่าตำแหน่ง เบี้ยเลี้ยง เบี้ยขยัน โบนัส อื่นๆ' }
    eventually { expect(page).to have_content 'รวมทั้งหมด' }
  end

  it 'should see month latest' do
    visit "/somsri_payroll#/payroll"
    sleep(1)
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00/i }
    eventually { expect(page).to have_content /นาย สมจิตร เป็นนักมวย.*1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00/i }
    eventually { expect(page).to have_content /พี ดี เอ็ม.*1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*3,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00/i }
  end

  it 'should see month list' do
    visit "/somsri_payroll#/payroll"

    find('#month-list').click
    sleep(1)
    eventually { expect(page).to have_content '1 ธันวาคม 2559 1 พฤศจิกายน 2559' }
  end

  it 'should switch month' do
    visit "/somsri_payroll#/payroll"
    find('#month-list').click
    sleep(1)
    click_on("พฤศจิกายน 2559")
    sleep(1)

    eventually { expect(page).to have_content 'รายการได้รายการหัก' }
    eventually { expect(page).to have_content 'รหัส ชื่อ' }
    eventually { expect(page).to have_content 'เงินเดือน เงินสอนพิเศษ ค่าตำแหน่ง เบี้ยเลี้ยง เบี้ยขยัน โบนัส อื่นๆ' }
    eventually { expect(page).to have_content 'ขาดงาน สาย ภาษี ประกันสังคม เงินสะสม เบิกล่วงหน้า อื่นๆ เงินเดือนสุทธิ' }
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*50,000.00 0.00 0.00 0.00 0.00 0.00 0.00/i }
    eventually { expect(page).to have_content /นาย สมจิตร เป็นนักมวย.*50,000.00 0.00 0.00 0.00 0.00 0.00 0.00/i }
    eventually { expect(page).to have_content /นาย คิง ฮาราบาส.*20.00 0.00 0.00 0.00 0.00 0.00 0.00/i }
    eventually { expect(page).not_to have_content 'พี ดี เอ็ม' }
    eventually { expect(page).to have_content /รวมทั้งหมด.*100,020.00 0.00 0.00 0.00 0.00 0.00 0.00/i }
  end

  describe 'employee link' do
    it 'go to employee detail and display payroll of the same month as payroll screen' do
      visit "/somsri_payroll#/payroll"
      sleep(1)
      find('#month-list').click
      sleep(1)
      click_on("1 พฤศจิกายน 2559")
      sleep(1)

      click_link "สมศรี เป็นชื่อแอพ"
      sleep(1)
      click_link "เงินเดือน"
      sleep(1)
      eventually { expect(page).to have_content '1 พฤศจิกายน 2559' }
      expect(find_field('ค่าแรง / เงินเดือนปัจจุบัน').value).to eq '50000'
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

  it 'should create new payroll' do
    login_as(user, scope: :user)
    visit "/somsri_payroll#/payroll"

    sleep(1)
    first('a[ng-click="payroll.createPayrolls()"]').trigger('click')
    sleep(1)
    find('input[type="text"]').set(DateTime.now.next_month(1).strftime("%d/%m/%Y"))
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    expect(page).to have_content(/นาง สมศรี เป็นชื่อแอพ.*1,000,000.00/i)
    expect(page).to have_content(/นาย สมจิตร เป็นนักมวย.*1,000,000.00/i)
  end

  it 'should warning before create new payrolls with same date' do
    visit "/somsri_payroll#/payroll"
    sleep(1)
    # craete payroll
    click_link('เริ่มออกเงินเดือน')
    sleep(1)
    find('#effective_date').set('13/12/2010')
    click_button('บันทึก')
    sleep(1)

    # craete same payroll
    visit "/somsri_payroll#/payroll"
    sleep(1)
    click_link('เริ่มออกเงินเดือน')
    sleep(1)
    find('#effective_date').set('13/12/2010')
    click_button('บันทึก')
    sleep(1)
    click_button('ตกลง')
    sleep(1)
    visit "/somsri_payroll#/payroll"
    sleep(1)
    find('#month-list').click
    sleep(1)
    find('ul.dropdown-menu li a', text: "13 ธันวาคม 2553").click
    sleep(1)
    expect(page).to have_content(/นาง สมศรี เป็นชื่อแอพ.*1,000,000.00/i)
    expect(page).to have_content('เงินเดือนสุทธิ')
  end
end
