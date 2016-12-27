describe 'Payroll Slip', js: true do
  let(:school) {school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" })}
  let(:user) { User.make!({ school_id: school.id }) }
  let(:employee) {employee = Employee.make!(
    {
      school_id: school.id,
      first_name: "Somsri",
      middle_name: "Is",
      last_name: "Appname",
      prefix: "Mrs.",
      first_name_thai: "สมศรี",
      last_name_thai: "เป็นชื่อแอพ",
      prefix_thai: "นาง",
      personal_id: "1409733340586",
      position: "ครูน้อย",
      account_number: "5-234-34532-2342",
      salary: 50000
    }
  )}
  let(:payrolls) do
    [
      pr1 = Payroll.make!({
        employee_id: employee.id,
        salary: 25_000,
        allowance: 2_500,
        tax: 968,
        social_insurance: 750,
        late: 500,
        pvf: 100,
        created_at: DateTime.new(2015, 2, 11)
      }),
      pr2 = Payroll.make!({
        employee_id: employee.id,
        salary: 25_000,
        allowance: 2_500,
        tax: 968,
        social_insurance: 750,
        late: 500,
        pvf: 1000,
        created_at: DateTime.new(2016, 2, 16)
      }),
      pr3 = Payroll.make!({
        employee_id: employee.id,
        salary: 50_000,
        tax: 100,
        pvf: 100,
        created_at: DateTime.new(2016, 1, 1)
      }),
    ]
  end

  before do
    payrolls
    login_as(user, scope: :user)
  end

  it 'should see label and data in employee slip' do
    visit "/#/employees/#{employee.id}/slip"
    sleep(1)
    sleep(1)
    eventually { expect(page).to have_content 'ตำแหน่ง/Title ครูน้อย' }
    eventually { expect(page).to have_content 'รหัส/Code 00001 ชื่อ/Name นาง สมศรี เป็นชื่อแอพ เลขที่บัญชี/Bank acct. 5-234-34532-2342'}
    eventually { expect(page).to have_content 'รายการได้ / Income จำนวนเงิน / Amount รายการเงินหัก / Deduction จำนวนเงิน / Amount'}
    eventually { expect(page).to have_content 'วัน / เดือน / ปี Day / Month / Year 29/02/59'}
    eventually { expect(page).to have_content 'รายได้สะสมต่อปี Acc. Income ภาษีสะสมต่อปี Acc. Tax เงินประกันสังคมสะสมต่อปี Acc. Social fund เงินสะสมกองทุนสงเคราะห์ Private Teacher Aid fund'}
  end

  it 'should see order is value greater than zero' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_content 'เงินเดือน / Salary ก.พ. 59' }
    eventually { expect(page).to have_content 'เบี้ยเลี้ยง / Shift'}
    eventually { expect(page).to have_content 'สาย / Late'}
    eventually { expect(page).to have_content 'ภาษี / Tax'}
    eventually { expect(page).to have_content 'ประกันสังคม / Social Sec.'}
    eventually { expect(page).to have_content 'เงินสะสมกองทุนสงเคราะห์ / Private Teacher Aid fund'}
  end

  it 'should not see order is value less than zero' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_no_content 'เบี้ยขยัน / Attendance Bonus' }
    eventually { expect(page).to have_no_content 'เงินสอนพิเศษ / After School Class' }
    eventually { expect(page).to have_no_content 'โบนัส / Bonus' }
    eventually { expect(page).to have_no_content 'ค่าตำแหน่ง / Position' }
    eventually { expect(page).to have_no_content 'รายได้อื่นๆ / Etc.' }
    eventually { expect(page).to have_no_content 'ขาดงาน / Absence' }
    eventually { expect(page).to have_no_content 'หักอื่นๆ / Etc.' }
    eventually { expect(page).to have_no_content 'เบิกล่วงหน้า / Adv. Payment' }
  end

  it 'should see order and value' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_content 'เงินเดือน / Salary ก.พ. 59 เบี้ยเลี้ยง / Shift' }
    eventually { expect(page).to have_content '25,000.00 2,500.00'}
    eventually { expect(page).to have_content 'ภาษี / Tax ประกันสังคม / Social Sec. สาย / Late เงินสะสมกองทุนสงเคราะห์ / Private Teacher Aid fund'}
    eventually { expect(page).to have_content '968.00 750.00 500.00 1,000.00'}
  end

  it 'should see net salary' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_content 'เงินรับสุทธิ Net Income 24,282.00' }
  end

  it 'should see total value on month' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_content 'รวมรายได้ Total Income 27,500.00' }
    eventually { expect(page).to have_content 'รวมรายการหัก Total Deduction 3,218.00'}
  end

  it 'should see total value on year' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_content 'รายได้สะสมต่อปี Acc. Income ภาษีสะสมต่อปี Acc. Tax เงินประกันสังคมสะสมต่อปี Acc. Social fund เงินสะสมกองทุนสงเคราะห์ Private Teacher Aid fund' }
    eventually { expect(page).to have_content '74,082.00 1,068.00 750.00 1,100.00' }
  end
end
