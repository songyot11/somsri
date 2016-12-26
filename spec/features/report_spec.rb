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
      account_number: "5-234-34532-0000",
      salary: 20
    }
  )}

  let(:payrolls) do
    [
      pr1 = Payroll.make!({employee_id: employee1.id, salary: 1_000_000, tax: 100,
                            created_at: DateTime.new(2016, 12, 1)}),
      pr3 = Payroll.make!({employee_id: employee2.id, salary: 1_000_000, tax: 100,
                            created_at: DateTime.new(2016, 12, 1)}),
      pr2 = Payroll.make!({employee_id: employee1.id, salary: 50_000, tax: 100,
                            created_at: DateTime.new(2016, 11, 1)}),
      pr4 = Payroll.make!({employee_id: employee2.id, salary: 50_000, tax: 100,
                            created_at: DateTime.new(2016, 11, 1)}),
      pr5 = Payroll.make!({employee_id: employee3.id, salary: 20, tax: 10,
                            created_at: DateTime.new(2016, 11, 1)}),
    ]
  end

  before do
    payrolls
    login_as(user, scope: :user)
  end
  it 'should see header table' do
    visit "/#/report"
    eventually { expect(page).to have_content 'รหัส ชื่อ เลขบัญชี เงินเดือน เงินเพิ่ม เงินหัก เงินเดือนสุทธิ' }
    eventually { expect(page).to have_content 'รวมทั้งหมด' }
  end

  it 'should see month latest' do
    visit "/#/report"

    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 1,000,000.00 0.00 100.00 999,900.00' }
    eventually { expect(page).to have_content 'สมจิตร เป็นนักมวย 5-234-34532-2342 1,000,000.00 0.00 100.00 999,900.00' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 2,000,000.00 0.00 200.00 1,999,800.00' }
  end

  it 'should see month list' do
    visit "/#/report"

    find('#month-list').click
    sleep(1)
    eventually { expect(page).to have_content 'ธันวาคม 2016 พฤศจิกายน 2016' }
  end

  it 'should switch month' do
    visit "/#/report"
    find('#month-list').click
    click_on("พฤศจิกายน 2016")

    eventually { expect(page).to have_content 'รหัส ชื่อ เลขบัญชี เงินเดือน เงินเพิ่ม เงินหัก เงินเดือนสุทธิ' }
    eventually { expect(page).to have_content 'สมศรี เป็นชื่อแอพ 5-234-34532-2342 50,000.00 0.00 100.00 49,900.00' }
    eventually { expect(page).to have_content 'สมจิตร เป็นนักมวย 5-234-34532-2342 50,000.00 0.00 100.00 49,900.00' }
    eventually { expect(page).not_to have_content 'ฮาราบาส' }
    eventually { expect(page).not_to have_content 'Harabas' }
    eventually { expect(page).to have_content 'รวมทั้งหมด 100,000.00 0.00 200.00 99,800.00' }
  end
end
