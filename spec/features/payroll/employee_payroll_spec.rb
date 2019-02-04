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
      pay_social_insurance: true,
      pay_pvf: true,
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
      Payroll.update(employee1.payrolls[0].id,{ salary: 1_000_000, social_insurance: 750 }),
      Payroll.update(employee2.payrolls[0].id,{ salary: 1_000_000, social_insurance: 750 }),
      Payroll.make!({employee_id: employee1.id, salary: 50_000,
                            effective_date: DateTime.new(2016, 11, 1),
                            tax: 9999,
                            social_insurance: 999,
                            pvf: 99 }),
      Payroll.make!({employee_id: employee2.id, salary: 50_000,
                            effective_date: DateTime.new(2016, 11, 1)}),
      Payroll.make!({employee_id: employee3.id, salary: 20,
                            effective_date: DateTime.new(2016, 11, 1)}),
      Payroll.update(employee4.payrolls[0].id,{ salary: 1_000_000 }),
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

  let(:taxs) do
    [
      taxR1 = TaxReduction.make!({ employee_id: employee1.id, pension_insurance: 300000,
        pension_fund: 0, government_pension_fund: 0, private_teacher_aid_fund: 0, retirement_mutual_fund: 0,
        national_savings_fund: 0, expenses: 60000, no_income_spouse: 60000, father_alimony: 0, mother_alimony: 0,
        spouse_father_alimony: 0, spouse_mother_alimony: 0, cripple_alimony: 0, insurance: 0, child: 0,
        father_insurance: 0, mother_insurance: 0, spouse_father_insurance: 0, spouse_mother_insurance: 0,
        long_term_equity_fund: 100000, social_insurance: 0, double_donation: 0, donation: 0, other: 0,
        spouse_insurance: 0, house_loan_interest: 0}).to_json,
      taxR2 = TaxReduction.make!({ employee_id: employee2.id, expenses: 60000 }).to_json
    ]
  end

  before do
    user.add_role :admin
    taxs
    taxrates
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
    eventually { expect(page).to_not have_content 'สำหรับประกันสังคม' }
    eventually { expect(page).to have_content 'ออกเงินเดือน' }
  end

  it 'should see month list' do
    visit "/somsri_payroll#/payroll"
    find('#month-list').click
    sleep(1)
    eventually { expect(page).to have_content 'เดือนปัจจุบัน 1 พฤศจิกายน 2559' }
    eventually { expect(page).to_not have_content 'เดือนปัจจุบัน เดือนปัจจุบัน 1 พฤศจิกายน 2559' }
  end

  it 'should see month list' do
    visit "/somsri_payroll#/payroll"
    find('#month-list').click
    sleep(1)
    click_on("1 พฤศจิกายน 2559")
    sleep(1)
    find('#month-list').click
    sleep(1)
    eventually { expect(page).to have_content '1 พฤศจิกายน 2559 เดือนปัจจุบัน' }
    eventually { expect(page).to_not have_content '1 พฤศจิกายน 2559 1 พฤศจิกายน 2559 เดือนปัจจุบัน' }
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

  it 'should display histories tax, pvf and social insurance' do
    visit "/somsri_payroll#/payroll"
    find('#month-list').click
    sleep(1)
    click_on("พฤศจิกายน 2559")
    sleep(1)
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*50,000.00 0.00 0.00 0.00 0.00 0.00 0.00/i }
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
    expect(page).to have_content 'คิง ฮาราบาส'
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

    expect(page).to have_content 'คิง ฮาราบาส'
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

    expect(page).to_not have_content 'คิง ฮาราบาส'
    expect(page).to_not have_content 'นาย สมจิตร เป็นนักมวย'
    expect(page).to_not have_content 'นาง สมศรี เป็นชื่อแอพ'
  end

  it 'should create new payroll' do
    login_as(user, scope: :user)
    visit "/somsri_payroll#/payroll"
    count = Payroll.all.count
    sleep(1)
    first('a[ng-click="payroll.createPayrolls()"]').trigger('click')
    sleep(1)
    find('input[type="text"]').set(DateTime.now.next_month(1).strftime("%d/%m/%Y"))
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)
    click_button('ตกลง')
    sleep(1)
    expect(count < Payroll.all.count).to eq true
  end

  it 'should warning before create new payrolls with same date' do
    visit "/somsri_payroll#/payroll"
    sleep(1)
    # craete payroll
    click_link('ออกเงินเดือน')
    sleep(1)
    find('#effective_date').set('13/12/2010')
    click_button('บันทึก')
    sleep(1)
    click_button('ตกลง')
    sleep(1)

    # craete same payroll
    visit "/somsri_payroll#/payroll"
    sleep(1)
    click_link('ออกเงินเดือน')
    sleep(1)
    find('#effective_date').set('13/12/2010')
    click_button('บันทึก')
    sleep(1)
    expect(page).to have_content('ไม่สามารถออกเงินเดือนซ้ำได้')
    sleep(1)
    click_button('ตกลง')
    sleep(1)
    expect(page).to have_content(/นาง สมศรี เป็นชื่อแอพ.*1,000,000.00/i)
    expect(page).to have_content('เงินเดือนสุทธิ')
  end

  it 'should create new payroll' do
    login_as(user, scope: :user)
    visit "/somsri_payroll#/payroll"
    count = Payroll.all.count
    sleep(1)
    first('a[ng-click="payroll.createPayrolls()"]').trigger('click')
    sleep(1)
    find('input[type="text"]').set(DateTime.now.next_month(1).strftime("%d/%m/%Y"))
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)
    click_button('ตกลง')
    sleep(1)
    expect(count < Payroll.all.count).to eq true

    sleep(1)
    find('#month-list').click
    sleep(1)
    expect(page).to have_content('เดือนปัจจุบัน')
    expect(page).to have_content('1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 304,654.17 750.00 30,000.00 0.00 0.00 664,595.83')
  end

end
