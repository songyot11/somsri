describe 'Payroll Slip', js: true do  
  let(:school) {school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" })}
  let(:employee) {employee = Employee.make!(
    {     
      school_id: school.id,
      first_name: "สมศรี",
      last_name: "เป็นชื่อแอพ",
      prefix: "นาง",
      sex: 1,
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
        created_at: DateTime.new(2015, 2, 11)
      }),
      pr2 = Payroll.make!({
        employee_id: employee.id,
        salary: 25_000,
        allowance: 2_500, 
        tax: 968,
        social_insurance: 750, 
        late: 500,
        created_at: DateTime.new(2016, 2, 16)
      }),
      pr3 = Payroll.make!({
        employee_id: employee.id, 
        salary: 50_000, 
        tax: 100, 
        created_at: DateTime.new(2016, 1, 1)
      }),
    ]
  end

  before do 
    payrolls
  end
  
  it 'should see label and data in employee slip' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_content 'เลขที่บัญชี/Bank acct. 5-234-34532-2342' }
    eventually { expect(page).to have_content 'รหัส/Code 00001 ชื่อ/Name นาง สมศรี เป็นชื่อแอพ ตำแหน่ง/Position ครูน้อย'}
    eventually { expect(page).to have_content 'รายการได้ / Income จำนวนเงิน / Amount รายการเงินหัก / Deduction จำนวนเงิน / Amount'}
    eventually { expect(page).to have_content 'วัน / เดือน / ปี DD / MM / YY 29/02/59'}
    eventually { expect(page).to have_content 'รายได้สะสมต่อปี Acc. Income ภาษีสะสมต่อปี Acc. Tax เงินประกันสังคมสะสมต่อปี Acc. Social fund'}
  end

  it 'should see order is value greater than zero' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_content 'เงินเดือน / Salary ก.พ. 59' }
    eventually { expect(page).to have_content 'เบี้ยเลี้ยง / Shift'}
    eventually { expect(page).to have_content 'สาย / Late'}
    eventually { expect(page).to have_content 'ภาษี / Tax'}
    eventually { expect(page).to have_content 'ประกันสังคม / Social Sec.'}
  end

  it 'should not see order is value less than zero' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_no_content 'เบี้ยขยัน / Attendance Bonus' }
    eventually { expect(page).to have_no_content 'ค่าล่วงเวลา / OT.' }
    eventually { expect(page).to have_no_content 'โบนัส / Bonus' }
    eventually { expect(page).to have_no_content 'ค่าตำแหน่ง / Position' }
    eventually { expect(page).to have_no_content 'รายได้อื่นๆ / Etc.' }
    eventually { expect(page).to have_no_content 'ขาดงาน / Absence' }
    eventually { expect(page).to have_no_content 'หักอื่นๆ / Etc.' }
    eventually { expect(page).to have_no_content 'เงินสะสมเข้ากองทุน PVF / PVF.' }
    eventually { expect(page).to have_no_content 'เบิกล่วงหน้า / Adv. Payment' }
  end

  it 'should see order and value' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_content 'เงินเดือน / Salary ก.พ. 59 เบี้ยเลี้ยง / Shift' }
    eventually { expect(page).to have_content '25,000.00 2,500.00'}
    eventually { expect(page).to have_content 'สาย / Late ภาษี / Tax ประกันสังคม / Social Sec'}
    eventually { expect(page).to have_content '500.00 968.00 750.00'}
  end

  it 'should see net salary' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_content 'เงินรับสุทธิ Net Income 25,282.00' }
  end

  it 'should see total value on month' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_content 'รวมรายได้ Total Income 27,500.00' }
    eventually { expect(page).to have_content 'รวมรายการหัก Total Deduction 2,218.00'}
  end

  it 'should see total value on year' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_content 'รายได้สะสมต่อปี Acc. Income ภาษีสะสมต่อปี Acc. Tax เงินประกันสังคมสะสมต่อปี Acc. Social fund' }
    eventually { expect(page).to have_content '75,182.00 1,068.00 750.00' }
  end
end
