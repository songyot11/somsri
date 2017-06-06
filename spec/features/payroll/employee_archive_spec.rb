describe 'Employee archive', js: true do
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
      first_name_thai: "สมชาย",
      last_name_thai: "เป็นน้องสมปอง",
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
      first_name_thai: "สมทรง",
      last_name_thai: "ยอดนักรบ",
      prefix_thai: "นาย",
      sex: 1,
      account_number: "5-234-34532-2342",
      salary: 20000
    }
  )}

  let(:employee3) {employee3 = Employee.make!(
    {
      school_id: school.id,
      first_name: "Somchit",
      middle_name: "Is",
      last_name: "Boxing",
      prefix: "Mr",
      first_name_thai: "กล้าหาญ",
      last_name_thai: "ชาญชัย",
      prefix_thai: "นาย",
      sex: 1,
      account_number: "5-234-34532-2342",
      salary: 20000
    }
  )}

  let(:payrolls) do
    [

      pr2 = Payroll.make!({employee_id: employee1.id, salary: 50_000, tax: 100,
                            effective_date: DateTime.new(2016, 11, 1)}),
      pr3 = Payroll.make!({employee_id: employee2.id, salary: 50_000, tax: 100,
                            effective_date: DateTime.new(2016, 11, 1)}),
      pr3 = Payroll.make!({employee_id: employee2.id, salary: 50_000, tax: 100,
                            effective_date: DateTime.new(2016, 12, 1)})
    ]
  end

  before do
    user.add_role :admin
    payrolls
    login_as(user, scope: :user)
  end

  it 'should show all employee' do
    visit "/somsri_payroll#/employees"

    eventually { expect(page).to have_content('สมทรง ยอดนักรบ') }
    eventually { expect(page).to have_content('สมชาย เป็นน้องสมปอง') }
  end

  it 'should archive employee' do
    visit "/somsri_payroll#/employees/#{employee1.id}"
    sleep(1)
    click_button('ลบ')
    sleep(1)
    click_button("ตกลง")
    sleep(1)
    employee1.reload

    eventually { expect(employee1.deleted_at).to_not eq(nil) }
  end

  it 'should restore employee' do
    visit "/somsri_payroll#/employees/#{employee1.id}"
    sleep(1)
    click_button('ลบ')
    sleep(1)
    click_button("ตกลง")
    sleep(1)
    employee1.reload
    eventually { expect(employee1.deleted_at).to_not eq(nil) }

    visit "/somsri_payroll#/employees/#{employee1.id}"
    sleep(1)
    click_button('นำข้อมูลกลับ')
    sleep(1)
    click_button("ตกลง")
    sleep(1)
    employee1.reload

    eventually { expect(employee1.deleted_at).to eq(nil) }
  end

  it 'should destory employee' do
    visit "/somsri_payroll#/employees/#{employee3.id}"
    eventually {expect(page) .to have_content('กล้าหาญ ชาญชัย')}
    sleep(1)
    click_button('ลบ')
    sleep(1)
    click_button("ตกลง")
    sleep(1)

    eventually { expect(page).to have_no_content("กล้าหาญ ชาญชัย") }
  end
end
