describe 'Payroll Edit', js: true do
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
      account_number: "5-234-34532-0000",
      salary: 20
    }
  )}

  let(:payrolls) do
    [
      pr1 = Payroll.make!({employee_id: employee1.id, salary: 1_000_000, tax: 100,
                            effective_date: DateTime.new(2016, 12, 1)}),
      pr3 = Payroll.make!({employee_id: employee2.id, salary: 1_000_000, tax: 100,
                            effective_date: DateTime.new(2016, 12, 1)}),
      pr2 = Payroll.make!({employee_id: employee1.id, salary: 50_000, tax: 100,
                            effective_date: DateTime.new(2016, 11, 1)}),
      pr4 = Payroll.make!({employee_id: employee2.id, salary: 50_000, tax: 100,
                            effective_date: DateTime.new(2016, 11, 1)}),
      pr5 = Payroll.make!({employee_id: employee3.id, salary: 20, tax: 10,
                            effective_date: DateTime.new(2016, 11, 1)}),
    ]
  end

  before do
    payrolls
    login_as(user, scope: :user)
  end

  it 'should edit salary' do
    visit "/somsri_payroll#/payroll"
    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.salary).to eq 1_000_000.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 999,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 1,999,800.00' }

    sleep(1)
    first('a[editable-number="employee.salary"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.salary).to eq 5000.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 5,000.00 0.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 4,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 1,005,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 1,004,800.00' }
  end

  it 'should edit allowance' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.allowance).to eq 0.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 999,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 1,999,800.00' }

    sleep(1)
    sleep(1)
    first('a[editable-number="employee.allowance"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.allowance).to eq 5000.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 5,000.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 1,004,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 5,000.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 2,004,800.00' }
  end

  it 'should edit attendance_bonus' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.attendance_bonus).to eq 0.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 999,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 1,999,800.00' }

    sleep(1)
    first('a[editable-number="employee.attendance_bonus"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.attendance_bonus).to eq 5000.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 5,000.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 1,004,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 5,000.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 2,004,800.00' }
  end

  it 'should edit ot' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.ot).to eq 0.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 999,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 1,999,800.00' }

    sleep(1)
    first('a[editable-number="employee.ot"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.ot).to eq 5000.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 5,000.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 1,004,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 5,000.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 2,004,800.00' }
  end

  it 'should edit bonus' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.bonus).to eq 0.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 999,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 1,999,800.00' }

    sleep(1)
    first('a[editable-number="employee.bonus"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.bonus).to eq 5000.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 5,000.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 1,004,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 5,000.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 2,004,800.00' }
  end

  it 'should edit position_allowance' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.position_allowance).to eq 0.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 999,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 1,999,800.00' }

    sleep(1)
    first('a[editable-number="employee.position_allowance"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.position_allowance).to eq 5000.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 5,000.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 1,004,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 5,000.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 2,004,800.00' }
  end

  it 'should edit extra_etc' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.extra_etc).to eq 0.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 999,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 1,999,800.00' }

    sleep(1)
    first('a[editable-number="employee.extra_etc"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.extra_etc).to eq 5000.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 5,000.00  100.00 0.00 0.00 0.00 0.00 0.00 0.00 1,004,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 5,000.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 2,004,800.00' }
  end

  it 'should edit absence' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.absence).to eq 0.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 999,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 1,999,800.00' }

    sleep(1)
    first('a[editable-number="employee.absence"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.absence).to eq 5000.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00  100.00 0.00 0.00 5,000.00 0.00 0.00 0.00 994,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 5,000.00 0.00 0.00 0.00 1,994,800.00' }
  end

  it 'should edit late' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.late).to eq 0.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 999,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 1,999,800.00' }


    sleep(1)
    first('a[editable-number="employee.late"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.late).to eq 5000.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00  100.00 0.00 0.00 0.00 5,000.00 0.00 0.00 994,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 5,000.00 0.00 0.00 1,994,800.00' }
  end

  it 'should edit tax' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.tax).to eq 100.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 999,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 1,999,800.00' }

    sleep(1)
    first('a[editable-number="employee.tax"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.tax).to eq 5000.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 5,000.00 0.00 0.00 0.00 0.00 0.00 0.00 995,000.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 5,100.00 0.00 0.00 0.00 0.00 0.00 0.00 1,994,900.00' }
  end

  it 'should edit social_insurance' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.social_insurance).to eq 0.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 999,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 1,999,800.00' }

    sleep(1)
    first('a[editable-number="employee.social_insurance"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.social_insurance).to eq 5000.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00  100.00 5,000.00 0.00 0.00 0.00 0.00 0.00 994,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 5,000.00 0.00 0.00 0.00 0.00 0.00 1,994,800.00' }
  end

  it 'should edit fee_etc' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.social_insurance).to eq 0.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 999,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 1,999,800.00' }

    sleep(1)
    first('a[editable-number="employee.fee_etc"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.fee_etc).to eq 5000.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00  100.00 0.00 0.00 0.00 0.00 0.00 5,000.00 994,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 5,000.00 1,994,800.00' }
  end

  it 'should edit pvf' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.pvf).to eq 0.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 999,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 1,999,800.00' }

    sleep(1)
    first('a[editable-number="employee.pvf"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.pvf).to eq 5000.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00  100.00 0.00 5,000.00 0.00 0.00 0.00 0.00 994,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 5,000.00 0.00 0.00 0.00 0.00 1,994,800.00' }
  end

  it 'should edit advance_payment' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.advance_payment).to eq 0.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 999,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 1,999,800.00' }

    sleep(1)
    first('a[editable-number="employee.advance_payment"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.advance_payment).to eq 5000.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00  100.00 0.00 0.00 0.00 0.00 5,000.00 0.00 994,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 5,000.00 0.00 1,994,800.00' }
  end

  it 'should default 0.00 when empty' do
    visit "/somsri_payroll#/payroll"

    sleep(1)
    first('a[editable-number="employee.salary"]').click
    sleep(1)
    find(:css, "input").set("")
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.salary).to eq 0.00 }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 0.00 0.00 0.00 0.00 0.00 0.00 0.00 100.00 0.00 0.00 0.00 0.00 0.00 0.00 -100.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 200.00 0.00 0.00 0.00 0.00 0.00 0.00 999,800.00' }
  end
end
