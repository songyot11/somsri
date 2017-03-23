describe 'Abilities', js: true do

  let(:school) do
      School.make!({ name: "โรงเรียนแห่งหนึ่ง" })
  end

  let(:users) do
    [
      User.make!({ school_id: school.id }),
      User.make!({ school_id: school.id })
    ]
  end

  before do
    users[0].add_role :admin
    users[1].add_role :finance_officer
  end

  describe 'Admin abilities' do
    before do
      login_as(users[0])
    end

    it 'can goto main menu' do
      visit "/"
      expect(page).to have_current_path '/'
      expect(page).to have_content 'เงินเดือน ค่าเทอม นับแถว บุคลากร ผู้ปกครอง นักเรียน'
    end

    it 'can goto payroll menu' do
      visit "/somsri_payroll"
      expect(page).to have_current_path '/somsri_payroll'
      expect(page).to have_content 'เงินเดือน รายงาน ตั้งค่า'
    end

    it 'can goto payroll' do
      visit "/somsri_payroll#/payroll"
      expect(page).to have_content 'เงินสอนพิเศษ	ค่าตำแหน่ง เบี้ยเลี้ยง เบี้ยขยัน โบนัส อื่นๆ'
    end

    it 'can goto payroll report' do
      visit "/somsri_payroll#/report"
      expect(page).to have_content 'รหัส ชื่อ เลขบัญชี เงินเดือน'
    end

    it 'can goto payroll setting' do
      visit "/somsri_payroll#/setting"
      expect(page).to have_content 'ชื่อ อีเมล รหัสผ่าน เปลี่ยนรหัสผ่าน'
    end

    it 'can goto invoice menu' do
      visit "/somsri_invoice"
      expect(page).to have_content 'ชำระเงิน รายงาน ใบเสร็จ'
    end

    it 'can goto invoice create' do
      visit "/somsri_invoice#/invoice"
      expect(page).to have_content 'แบบชำระเงิน'
    end

    it 'can goto invoice create' do
      visit "/somsri_invoice#/invoice"
      expect(page).to have_content 'แบบชำระเงิน'
    end

    it 'can goto invoice report menu' do
      visit "/somsri_invoice#/report"
      expect(page).to have_content 'รายงานค่าเทอม รายงานประจำวัน'
    end

    it 'can goto invoice student report' do
      visit "/somsri_invoice#/student_report"
      expect(page).to have_content 'สถานะ ชำระโดย ค่าธรรมเนียมการศึกษา'
    end

    it 'can goto invoice daily report' do
      visit "/somsri_invoice#/daily_report"
      expect(page).to have_content 'นำส่งเงิน'
    end

    it 'can goto invoice report' do
      visit "/somsri_invoice#/invoice_report"
      expect(page).to have_content 'Invoice # ชื่อนักเรียน ชั้น'
    end

    it 'can goto employees' do
      visit "/somsri_payroll#/employees"
      expect(page).to have_content '+ เพิ่มพนักงานใหม่'
    end

    it 'can goto parents' do
      visit "/parents"
      expect(page).to have_content 'ผู้ปกครอง'
    end

    it 'can goto students' do
      visit "/students"
      expect(page).to have_content 'นักเรียน'
    end
  end

  describe 'Finance Officer abilities' do
    before do
      login_as(users[1])
    end

    it 'can goto main menu' do
      visit "/"
      expect(page).to have_current_path '/'
      expect(page).to have_content 'เงินเดือน ค่าเทอม นับแถว บุคลากร ผู้ปกครอง นักเรียน'
    end

    it 'can goto payroll menu' do
      visit "/somsri_payroll"
      expect(page).to have_current_path '/'
      expect(page).to have_content 'บัญชีของคุณไม่สามารถใช้งานฟังก์ชันนี้ได้'
      expect(page).to have_content 'เงินเดือน ค่าเทอม นับแถว บุคลากร ผู้ปกครอง นักเรียน'
    end

    it 'can goto payroll' do
      visit "/somsri_payroll#/payroll"
      expect(page).to have_content 'บัญชีของคุณไม่สามารถใช้งานฟังก์ชันนี้ได้'
      expect(page).to have_content 'เงินเดือน ค่าเทอม นับแถว บุคลากร ผู้ปกครอง นักเรียน'
    end

    it 'can goto payroll report' do
      visit "/somsri_payroll#/report"
      expect(page).to have_content 'บัญชีของคุณไม่สามารถใช้งานฟังก์ชันนี้ได้'
      expect(page).to have_content 'เงินเดือน ค่าเทอม นับแถว บุคลากร ผู้ปกครอง นักเรียน'
    end

    it 'can goto payroll setting' do
      visit "/somsri_payroll#/setting"
      expect(page).to have_content 'บัญชีของคุณไม่สามารถใช้งานฟังก์ชันนี้ได้'
      expect(page).to have_content 'เงินเดือน ค่าเทอม นับแถว บุคลากร ผู้ปกครอง นักเรียน'
    end

    it 'can goto invoice menu' do
      visit "/somsri_invoice"
      expect(page).to have_content 'ชำระเงิน รายงาน ใบเสร็จ'
    end

    it 'can goto invoice create' do
      visit "/somsri_invoice#/invoice"
      expect(page).to have_content 'แบบชำระเงิน'
    end

    it 'can goto invoice create' do
      visit "/somsri_invoice#/invoice"
      expect(page).to have_content 'แบบชำระเงิน'
    end

    it 'can goto invoice report menu' do
      visit "/somsri_invoice#/report"
      expect(page).to have_content 'รายงานค่าเทอม รายงานประจำวัน'
    end

    it 'can goto invoice student report' do
      visit "/somsri_invoice#/student_report"
      expect(page).to have_content 'สถานะ ชำระโดย ค่าธรรมเนียมการศึกษา'
    end

    it 'can goto invoice daily report' do
      visit "/somsri_invoice#/daily_report"
      expect(page).to have_content 'นำส่งเงิน'
    end

    it 'can goto invoice report' do
      visit "/somsri_invoice#/invoice_report"
      expect(page).to have_content 'Invoice # ชื่อนักเรียน ชั้น'
    end

    it 'can goto employees' do
      visit "/somsri_payroll#/employees"
      expect(page).to have_content 'บัญชีของคุณไม่สามารถใช้งานฟังก์ชันนี้ได้'
      expect(page).to have_content 'เงินเดือน ค่าเทอม นับแถว บุคลากร ผู้ปกครอง นักเรียน'
    end

    it 'can goto parents' do
      visit "/parents"
      expect(page).to have_content 'บัญชีของคุณไม่สามารถใช้งานฟังก์ชันนี้ได้'
      expect(page).to have_content 'เงินเดือน ค่าเทอม นับแถว บุคลากร ผู้ปกครอง นักเรียน'
    end

    it 'can goto students' do
      visit "/students"
      expect(page).to have_content 'นักเรียน'
    end
  end

end
