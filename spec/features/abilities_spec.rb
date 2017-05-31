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
      sleep(1)
      expect(page).to have_current_path '/'
      expect(page).to have_content 'เงินเดือน ค่าเทอม นับแถว บุคลากร ผู้ปกครอง นักเรียน'
    end

    it 'can goto main menu english' do
      visit "/?locale=en#"
      sleep(1)
      expect(page).to have_current_path '/?locale=en#'
      expect(page).to have_content 'Payrolls Invoices Rollcalls Employees Parents Students'
    end

    it 'can goto payroll menu' do
      visit "/somsri_payroll"
      sleep(1)
      expect(page).to have_current_path '/somsri_payroll'
      expect(page).to have_content 'เงินเดือน รายงาน'
    end

    it 'can goto payroll' do
      visit "/somsri_payroll#/payroll"
      sleep(1)
      expect(page).to have_content 'เงินสอนพิเศษ ค่าตำแหน่ง เบี้ยเลี้ยง เบี้ยขยัน โบนัส อื่นๆ'
    end

    it 'can goto payroll report' do
      visit "/somsri_payroll#/report"
      sleep(1)
      expect(page).to have_content 'รหัส ชื่อ เลขบัญชี เงินเดือน'
    end

    it 'can goto setting' do
      visit "/main#/setting"
      sleep(1)
      expect(page).to have_content 'ชื่อ อีเมล รหัสผ่าน เปลี่ยนรหัสผ่าน'
      expect(page).to have_content 'ชื่อโรงเรียน'
    end

    it 'can goto invoice menu' do
      visit "/somsri_invoice"
      sleep(1)
      expect(page).to have_content 'ชำระเงิน รายงาน ใบเสร็จ'
    end

    it 'can goto invoice create' do
      visit "/somsri_invoice#/invoice"
      sleep(1)
      expect(page).to have_content 'แบบชำระเงิน'
    end

    it 'can goto invoice report menu' do
      visit "/somsri_invoice#/report"
      sleep(1)
      expect(page).to have_content 'รายงานค่าเทอม รายงานประจำวัน'
    end

    it 'can goto invoice student report' do
      visit "/somsri_invoice#/student_report"
      sleep(1)
      expect(page).to have_content 'สถานะ ชำระโดย ค่าธรรมเนียมการศึกษา'
    end

    it 'can goto invoice daily report' do
      visit "/somsri_invoice#/daily_report"
      sleep(1)
      expect(page).to have_content 'นำส่งเงิน'
    end

    it 'can goto invoice report' do
      visit "/somsri_invoice#/invoice_report"
      sleep(1)
      expect(page).to have_content 'Invoice # ชื่อนักเรียน ชั้น'
    end

    it 'can goto employees' do
      visit "/somsri_payroll#/employees"
      sleep(1)
      expect(page).to have_content '+ เพิ่มพนักงานใหม่'
    end

    it 'can goto parents' do
      visit "/parents"
      sleep(1)
      expect(page).to have_content 'ผู้ปกครอง'
    end

    it 'can goto students' do
      visit "/students"
      sleep(1)
      expect(page).to have_content 'นักเรียน'
    end

  end

  describe 'Finance Officer abilities' do
    before do
      login_as(users[1])
    end

    let(:menu_content) { 'ค่าเทอม' }

    it 'can goto main menu' do
      visit "/"
      sleep(1)
      expect(page).to have_current_path '/'
      expect(page).to have_content menu_content
    end

    it 'cant goto payroll menu' do
      visit "/somsri_payroll"
      sleep(1)
      expect(page).to have_current_path '/'
      expect(page).to have_content 'บัญชีของคุณไม่สามารถใช้งานฟังก์ชันนี้ได้'
      expect(page).to have_content menu_content
    end

    it 'cant goto payroll' do
      visit "/somsri_payroll#/payroll"
      sleep(1)
      expect(page).to have_content 'บัญชีของคุณไม่สามารถใช้งานฟังก์ชันนี้ได้'
      expect(page).to have_content menu_content
    end

    it 'cant goto payroll report' do
      visit "/somsri_payroll#/report"
      sleep(1)
      expect(page).to have_content 'บัญชีของคุณไม่สามารถใช้งานฟังก์ชันนี้ได้'
      expect(page).to have_content menu_content
    end

    it 'can goto setting' do
      visit "/main#/setting"
      sleep(1)
      expect(page).to have_content 'ชื่อ อีเมล รหัสผ่าน เปลี่ยนรหัสผ่าน'
      expect(page).not_to have_content 'ชื่อโรงเรียน'
    end

    it 'can goto invoice menu' do
      visit "/somsri_invoice"
      sleep(1)
      expect(page).to have_content 'ชำระเงิน รายงาน ใบเสร็จ'
    end

    it 'can goto invoice create' do
      visit "/somsri_invoice#/invoice"
      sleep(1)
      expect(page).to have_content 'แบบชำระเงิน'
    end

    it 'can goto invoice create' do
      visit "/somsri_invoice#/invoice"
      sleep(1)
      expect(page).to have_content 'แบบชำระเงิน'
    end

    it 'can goto invoice report menu' do
      visit "/somsri_invoice#/report"
      sleep(1)
      expect(page).to have_content 'รายงานค่าเทอม รายงานประจำวัน'
    end

    it 'can goto invoice student report' do
      visit "/somsri_invoice#/student_report"
      sleep(1)
      expect(page).to have_content 'สถานะ ชำระโดย ค่าธรรมเนียมการศึกษา'
    end

    it 'can goto invoice daily report' do
      visit "/somsri_invoice#/daily_report"
      sleep(1)
      expect(page).to have_content 'นำส่งเงิน'
    end

    it 'can goto invoice report' do
      visit "/somsri_invoice#/invoice_report"
      sleep(1)
      expect(page).to have_content 'Invoice # ชื่อนักเรียน ชั้น'
    end

    it 'cant goto employees' do
      visit "/somsri_payroll#/employees"
      sleep(1)
      expect(page).to have_content 'บัญชีของคุณไม่สามารถใช้งานฟังก์ชันนี้ได้'
      expect(page).to have_content menu_content
    end

    it 'cant goto parents' do
      visit "/parents"
      sleep(1)
      expect(page).to have_content 'ผู้ปกครอง'
    end

    it 'can goto students' do
      visit "/students"
      sleep(1)
      expect(page).to have_content 'นักเรียน'
    end

    it 'cant goto rails_admin' do
      visit "/admin"
      sleep(1)
      expect(page).to have_current_path '/'
    end
  end

  describe 'Unauthenticated user abilities' do

    it 'can goto login page' do
      visit "/"
      sleep(1)
      expect(page).to have_current_path '/'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'cant goto payroll menu' do
      visit "/somsri_payroll"
      sleep(1)
      expect(page).to have_current_path '/'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'cant goto payroll' do
      visit "/somsri_payroll#/payroll"
      sleep(1)
      expect(page).to have_current_path '/'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'cant goto payroll report' do
      visit "/somsri_payroll#/report"
      sleep(1)
      expect(page).to have_current_path '/'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'cant goto setting' do
      visit "/main#/setting"
      sleep(1)
      expect(page).to have_current_path '/'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'cant goto invoice menu' do
      visit "/somsri_invoice"
      sleep(1)
      expect(page).to have_current_path '/'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'cant goto invoice create' do
      visit "/somsri_invoice#/invoice"
      sleep(1)
      expect(page).to have_current_path '/'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'cant goto invoice report menu' do
      visit "/somsri_invoice#/report"
      sleep(1)
      expect(page).to have_current_path '/'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'cant goto invoice student report' do
      visit "/somsri_invoice#/student_report"
      sleep(1)
      expect(page).to have_current_path '/'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'cant goto invoice daily report' do
      visit "/somsri_invoice#/daily_report"
      sleep(1)
      expect(page).to have_current_path '/'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'cant goto invoice report' do
      visit "/somsri_invoice#/invoice_report"
      sleep(1)
      expect(page).to have_current_path '/'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'cant goto employees' do
      visit "/somsri_payroll#/employees"
      sleep(1)
      expect(page).to have_current_path '/'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'cant goto parents' do
      visit "/parents"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'cant goto students' do
      visit "/students"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'Keep me signed in'
    end

  end

end
