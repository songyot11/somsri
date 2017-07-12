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
      account_number: "5-234-34532-2341"
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
      account_number: "5-234-34532-0000"
    }
  )}

  let(:payrolls) do
    [
      Payroll.update(employee1.payrolls[0].id,{ salary: 1_000 }),
      Payroll.update(employee2.payrolls[0].id,{ salary: 1_000 }),
      Payroll.make!({employee_id: employee1.id, salary: 1_000, closed: true,
                            effective_date: DateTime.new(2016, 11, 1)}),
      Payroll.make!({employee_id: employee2.id, salary: 1_000, closed: true,
                            effective_date: DateTime.new(2016, 11, 1)}),
      Payroll.make!({employee_id: employee3.id, salary: 1_000, closed: true,
                            effective_date: DateTime.new(2016, 11, 1)}),
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
    login_as(user)
  end

  it 'should edit salary' do
    visit "/somsri_payroll#/payroll"
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 1,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 2,000.00/i }

    payroll = Payroll.find(payrolls[0].id)
    eventually { expect(payroll.tax).to eq 0.00 }

    sleep(1)
    first('a[editable-number="employee.salary"]').click
    sleep(1)
    find(:css, "input").set(5000.0)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    eventually { expect(payroll.reload.salary).to eq 5000.0 }
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*5,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 5,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*6,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 6,000.00/i }
  end

  it 'should not display social_insurance_pdf button on current month' do
    visit "/somsri_payroll#/payroll"
    eventually { expect(page).to_not have_content /สำหรับประกันสังคม/i }
  end

  it 'should display social_insurance_pdf button on closed month' do
    visit "/somsri_payroll#/payroll"
    sleep(1)
    find('#month-list').click
    sleep(1)
    find('ul.dropdown-menu li a', text: "1 พฤศจิกายน 2559").click
    sleep(1)
    eventually { expect(page).to have_content /สำหรับประกันสังคม/i }
  end

  it 'should edit ot' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.ot).to eq 0.00 }
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 1,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 2,000.00/i }

    sleep(1)
    first('a[editable-number="employee.ot"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.ot).to eq 5000.0 }
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*1,000.00 5,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 6,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 5,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 7,000.00/i }
  end

  it 'should edit position_allowance' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.position_allowance).to eq 0.00 }
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 1,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 2,000.00/i }

    sleep(1)
    first('a[editable-number="employee.position_allowance"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.position_allowance).to eq 5000.0 }
    eventually { expect(page).to have_content /สมศรี เป็นชื่อแอพ.*1,000.00 0.00 5,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 6,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 5,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 7,000.00/i }
  end

  it 'should edit allowance' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.allowance).to eq 0.00 }
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 1,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 2,000.00/i }

    sleep(1)
    first('a[editable-number="employee.allowance"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.allowance).to eq 5000.0 }
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 5,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 6,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 5,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 7,000.00/i }
  end

  it 'should edit attendance_bonus' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.attendance_bonus).to eq 0.00 }
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 1,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 2,000.00/i }

    sleep(1)
    first('a[editable-number="employee.attendance_bonus"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.attendance_bonus).to eq 5000.0 }
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 5,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 6,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 5,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 7,000.00/i }
  end

  it 'should edit bonus' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.bonus).to eq 0.00 }
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 1,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 2,000.00/i }

    sleep(1)
    first('a[editable-number="employee.bonus"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.bonus).to eq 5000.0 }
    eventually { expect(page).to have_content /สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 5,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 6,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 5,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 7,000.00/i }
  end

  it 'should edit extra_etc' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.extra_etc).to eq 0.00 }
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 1,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 2,000.00/i }

    sleep(1)
    first('a[editable-number="employee.extra_etc"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.extra_etc).to eq 5000.0 }
    eventually { expect(page).to have_content /สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 0.00 5,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 6,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 0.00 5,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 7,000.00/i }
  end

  it 'should edit absence' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.absence).to eq 0.00 }
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 1,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 2,000.00/i }

    sleep(1)
    first('a[editable-number="employee.absence"]').click
    sleep(1)
    find(:css, "input").set(500)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.absence).to eq 500.0 }
    eventually { expect(page).to have_content /สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 0.00 0.00 500.00 0.00 0.00 0.00 0.00 0.00 0.00 500.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 0.00 0.00 500.00 0.00 0.00 0.00 0.00 0.00 0.00 1,500.00/i }
  end

  it 'should edit late' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.late).to eq 0.00 }
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 1,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 2,000.00/i }

    sleep(1)
    first('a[editable-number="employee.late"]').click
    sleep(1)
    find(:css, "input").set(500)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.late).to eq 500.0 }
    eventually { expect(page).to have_content /สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 500.00 0.00 0.00 0.00 0.00 0.00 500.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 500.00 0.00 0.00 0.00 0.00 0.00 1,500.00/i }
  end

  it 'should edit fee_etc' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.social_insurance).to eq 0.00 }
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 1,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 2,000.00/i }

    sleep(1)
    first('a[editable-number="employee.fee_etc"]').click
    sleep(1)
    find(:css, "input").set(500)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.fee_etc).to eq 500.0 }
    eventually { expect(page).to have_content /สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 500.00 500.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 500.00 1,500.00/i }
  end

  it 'should edit advance_payment' do
    visit "/somsri_payroll#/payroll"

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.advance_payment).to eq 0.00 }
    eventually { expect(page).to have_content /นาง สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 1,000.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 2,000.00/i }

    sleep(1)
    first('a[editable-number="employee.advance_payment"]').click
    sleep(1)
    find(:css, "input").set(500)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payroll = Payroll.find(payrolls[0].id)

    eventually { expect(payroll.advance_payment).to eq 500.00 }
    eventually { expect(page).to have_content /สมศรี เป็นชื่อแอพ.*1,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 500.00 0.00 500.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*2,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 500.00 0.00 1,500.00/i }
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
    eventually { expect(page).to have_content /สมศรี เป็นชื่อแอพ.*0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00/i }
    eventually { expect(page).to have_content /รวมทั้งหมด.*1,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 1,000.00/i }
  end

  it 'should update employee.salary if changed lasted payroll.salary' do
    visit "/somsri_payroll#/payroll"

    sleep(1)
    first('a[editable-number="employee.salary"]').click
    sleep(1)
    find(:css, "input").set(5000)
    sleep(1)
    find('button[type="submit"]').click
    sleep(1)

    payrolls[0].reload
    employee1.reload

    eventually { expect(payrolls[0].salary).to eq 5000.00 }
    eventually { expect(employee1.salary).to eq 5000.00 }
  end

  it 'should not update employee.salary if changed history payroll.salary' do
    visit "/somsri_payroll#/payroll"

    sleep(1)
    find('#month-list').click
    sleep(1)

    find('ul.dropdown-menu li a', text: "1 พฤศจิกายน 2559").click
    sleep(1)
    eventually { expect(first('a[editable-number="employee.salary"]')).to eq nil }
  end
end
