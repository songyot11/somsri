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

  let(:enable_rollcall) do
    SiteConfig.make!({ enable_rollcall: true })
  end

  let(:expenses) do
    [
      Expense.make!(
        effective_date: DateTime.now,
        expenses_id:'vanz114214',
        detail:'ค่ารถตู้ใหม่ผอ.',
        total_cost: 7500000
      )
    ]
  end

  before do
    users[0].add_role :admin
    users[1].add_role :finance_officer
    expenses
  end

  describe 'Admin abilities' do
    before do
      login_as(users[0])
      enable_rollcall
    end

    it 'can goto main menu english' do
      visit "/?locale=en#"
      sleep(1)
      expect(page).to have_current_path '/?locale=en#'
      expect(page).to have_content 'Payroll Invoice Attendance Employee Parent Student Alumnu'

    end

    it 'can goto payroll menu' do
      visit "/somsri_payroll"
      sleep(1)
      expect(page).to have_current_path '/somsri_payroll'
      expect(page).to have_content 'แก้ไข รายงาน'
    end

    it 'can goto payroll' do
      visit "/somsri_payroll#/payroll"
      sleep(1)
      expect(page).to have_content 'เงินสอนพิเศษ ค่าตำแหน่ง เบี้ยเลี้ยง เบี้ยขยัน โบนัส อื่นๆ'
    end

    it 'can goto payroll when locale=en' do
      visit "/somsri_payroll#/payroll"
      sleep(1)
      find("#navbarDropdownMenuLink").click
      find('.fa-commenting-o').hover
      find("a", :text => "English").click
      sleep(1)
      visit "/somsri_payroll#/payroll"
      sleep(1)
      expect(page).to have_content 'Fullname Total IncomeOutcome Salary OverTime Position'
    end

    it 'can goto main menu' do
      visit "/"
      sleep(1)
      expect(page).to have_current_path '/'
      expect(page).to have_content 'เงินเดือน ค่าเทอม นับแถว บุคลากร ผู้ปกครอง นักเรียน'
    end

    it 'can goto payroll report' do
      visit "/somsri_payroll#/report"
      sleep(2)
      expect(page).to have_content 'ลูกจ้างประจำลูกจ้างชั่วคราวลูกจ้างทดลองงานลูกจ้างรายวัน'
    end

    it 'can goto profile' do
      visit "/main#/profile"
      sleep(1)
      expect(page).to have_content 'ชื่อ อีเมล์ รหัสผ่าน เปลี่ยนรหัสผ่าน'
      expect(page).to have_content 'ชื่อโรงเรียน'
    end

    it 'can goto setting' do
      visit "/main#/setting"
      sleep(1)
      expect(page).to have_content 'จัดการชั้นเรียน'
    end

    it 'can goto invoice menu' do
      visit "/somsri_invoice"
      sleep(1)
      expect(page).to have_content 'ชำระเงิน ใบเสร็จ นำส่งเงิน รายงานการชำระ'
    end

    it 'can goto invoice create' do
      visit "/somsri_invoice#/invoice"
      sleep(1)
      expect(page).to have_content 'แบบชำระเงิน'
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
      expect(page).to have_content 'Invoice # ชื่อ-สกุลนักเรียน ระดับชั้น'
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

    it 'can goto setting expense tags' do
      visit "/somsri#/expenses/setting"
      sleep(1)
      expect(page).to have_content 'ตั้งค่าประเภทค่าใช้จ่าย'
    end

    it 'can goto expenses list' do
      visit "/somsri#/expenses"
      sleep(1)
      expect(page).to have_content 'บันทึกค่าใช้จ่าย'
    end

    it 'can goto create expenses' do
      visit "/somsri#/expenses/new"
      sleep(1)
      expect(page).to have_content 'เพิ่มรายการค่าใช้จ่าย'
    end

    it 'can goto edit expenses' do
      visit "/somsri#/expenses/1"
      sleep(1)
      expect(page).to have_content 'แก้ไขรายการค่าใช้จ่าย'
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

    it 'can goto profile' do
      visit "/main#/profile"
      sleep(1)
      expect(page).to have_content 'ชื่อ อีเมล์ รหัสผ่าน เปลี่ยนรหัสผ่าน'
      expect(page).not_to have_content 'ชื่อโรงเรียน'
    end

    it 'can goto profile' do
      visit "/main#/setting"
      sleep(1)
      expect(page).to have_content menu_content
    end

    it 'can goto invoice menu' do
      visit "/somsri_invoice"
      sleep(1)
      expect(page).to have_content 'ชำระเงิน ใบเสร็จ นำส่งเงิน รายงานการชำระ'
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

    it 'can goto setting expense tags' do
      visit "/somsri#/expenses/setting"
      sleep(1)
      expect(page).to have_current_path '/'
    end

    it 'can goto expenses list' do
      visit "/somsri#/expenses"
      sleep(1)
      expect(page).to have_content 'บันทึกค่าใช้จ่าย'
    end

    it 'can goto create expenses' do
      visit "/somsri#/expenses/new"
      sleep(1)
      expect(page).to have_content 'เพิ่มรายการค่าใช้จ่าย'
    end

    it 'can goto edit expenses' do
      visit "/somsri#/expenses/1"
      sleep(1)
      expect(page).to have_content 'แก้ไขรายการค่าใช้จ่าย'
    end
  end

  describe 'Unauthenticated user abilities' do

    it 'can goto login page' do
      visit "/"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'ให้ฉันอยู่ในระบบต่อไป'
    end

    it 'cant goto payroll menu' do
      visit "/somsri_payroll"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'ให้ฉันอยู่ในระบบต่อไป'
    end

    it 'cant goto payroll' do
      visit "/somsri_payroll#/payroll"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'ให้ฉันอยู่ในระบบต่อไป'
    end

    it 'cant goto payroll report' do
      visit "/somsri_payroll#/report"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'ให้ฉันอยู่ในระบบต่อไป'
    end

    it 'cant goto profile' do
      visit "/main#/profile"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'ให้ฉันอยู่ในระบบต่อไป'
    end

    it 'cant goto profile' do
      visit "/main#/setting"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'ให้ฉันอยู่ในระบบต่อไป'
    end

    it 'cant goto invoice menu' do
      visit "/somsri_invoice"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'ให้ฉันอยู่ในระบบต่อไป'
    end

    it 'cant goto invoice create' do
      visit "/somsri_invoice#/invoice"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'ให้ฉันอยู่ในระบบต่อไป'
    end

    it 'cant goto invoice report menu' do
      visit "/somsri_invoice#/report"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'ให้ฉันอยู่ในระบบต่อไป'
    end

    it 'cant goto invoice student report' do
      visit "/somsri_invoice#/student_report"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'ให้ฉันอยู่ในระบบต่อไป'
    end

    it 'cant goto invoice daily report' do
      visit "/somsri_invoice#/daily_report"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'ให้ฉันอยู่ในระบบต่อไป'
    end

    it 'cant goto invoice report' do
      visit "/somsri_invoice#/invoice_report"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'ให้ฉันอยู่ในระบบต่อไป'
    end

    it 'cant goto employees' do
      visit "/somsri_payroll#/employees"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'ให้ฉันอยู่ในระบบต่อไป'
    end

    it 'cant goto parents' do
      visit "/parents"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'ให้ฉันอยู่ในระบบต่อไป'
    end

    it 'cant goto students' do
      visit "/students"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'ให้ฉันอยู่ในระบบต่อไป'
    end

    it 'can goto setting expense tags' do
      visit "/somsri#/setting/expenses_tag"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'can goto expenses list' do
      visit "/somsri#/expenses"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'can goto create expenses' do
      visit "/somsri#/expenses/new"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'can goto edit expenses' do
      visit "/somsri#/expenses/1"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'can goto setting expense tags' do
      visit "/somsri#/setting/expenses_tag"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'can goto expenses list' do
      visit "/somsri#/expenses"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'can goto create expenses' do
      visit "/somsri#/expenses/new"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'Keep me signed in'
    end

    it 'can goto edit expenses' do
      visit "/somsri#/expenses/1"
      sleep(1)
      expect(page).to have_current_path '/users/sign_in'
      expect(page).to have_content 'Keep me signed in'
    end

  end

end
