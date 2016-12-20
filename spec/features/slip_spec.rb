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

    eventually { expect(page).to have_content 'เลขบัตรประจำตัวประชาชน 1409733340586' }
    eventually { expect(page).to have_content 'รหัส 1 ชื่อ นาง สมศรี เป็นชื่อแอพ ตำแหน่ง ครูน้อย'}
    eventually { expect(page).to have_content 'รายได้ จำนวนเงิน รายการหัก จำนวนเงิน'}
    eventually { expect(page).to have_content 'วัน/เดือน/ปี 29/02/59'}
    eventually { expect(page).to have_content 'รายได้สะสมต่อปี ภาษีสะสมต่อปี เงินประกันสังคมสะสมต่อปี'}
  end

  it 'should see order is value greater than zero' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_content 'เงินเดือน ก.พ. 59' }
    eventually { expect(page).to have_content 'เบี้ยเลี้ยง'}
    eventually { expect(page).to have_content 'สาย'}
    eventually { expect(page).to have_content 'ภาษี'}
    eventually { expect(page).to have_content 'ประกันสังคม'}
  end

  it 'should not see order is value less than zero' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_no_content 'เบี้ยขยัน' }
    eventually { expect(page).to have_no_content 'ค่าล่วงเวลา' }
    eventually { expect(page).to have_no_content 'โบนัส' }
    eventually { expect(page).to have_no_content 'ค่าตำแหน่ง' }
    eventually { expect(page).to have_no_content 'รายได้อื่นๆ' }
    eventually { expect(page).to have_no_content 'ขาดงาน' }
    eventually { expect(page).to have_no_content 'หักอื่นๆ' }
    eventually { expect(page).to have_no_content 'เงินสะสมเข้ากองทุน' }
    eventually { expect(page).to have_no_content 'เบิกล่วงหน้า' }
  end

  it 'should see order and value' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_content 'เงินเดือน ก.พ. 59 เบี้ยเลี้ยง' }
    eventually { expect(page).to have_content '25,000.00 2,500.00'}
    eventually { expect(page).to have_content 'สาย ภาษี ประกันสังคม'}
    eventually { expect(page).to have_content '500.00 968.00 750.00'}
  end

  it 'should see net salary' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_content 'เงินรับสุทธิ 25,282.00' }
  end

  it 'should see total value on month' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_content 'รวมรายได้ 27,500.00' }
    eventually { expect(page).to have_content 'รวมรายการหัก 2,218.00'}
  end

  it 'should see total value on year' do
    visit "/#/employees/#{employee.id}/slip"

    eventually { expect(page).to have_content 'รายได้สะสมต่อปี ภาษีสะสมต่อปี เงินประกันสังคมสะสมต่อปี' }
    eventually { expect(page).to have_content '75,182.00 1,068.00 750.00' }
  end
end
