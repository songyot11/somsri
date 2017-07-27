describe 'Payroll Swap Page', js: true do

  let(:school) {school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" })}
  let(:user) { User.make!({ school_id: school.id }) }

  before do
    user.add_role :admin
    login_as(user, scope: :user)
    SiteConfig.stub_chain("get_cache.enable_rollcall").and_return(true)
  end

  it 'should not see two menu on homepage' do
    visit "/"
    eventually { expect(page).to have_no_selector('#menu') }
  end

  it 'should see six menu and current page is Report' do
    visit "/somsri_payroll#/report"
    sleep(1)
    find('#menu').click
    sleep(1)
    eventually { expect(page).to have_content 'รายงาน เงินเดือน ค่าเทอม นับแถว บุคลากร ผู้ปกครอง นักเรียน' }
    eventually { expect(URI.parse(current_url).to_s).to have_content 'report' }
  end

  it 'should see six menu and current page is Employee' do
    visit "/somsri_payroll#/employees"
    sleep(1)
    find('#menu').click
    sleep(1)

    eventually { expect(page).to have_content 'บุคลากร เงินเดือน ค่าเทอม นับแถว บุคลากร ผู้ปกครอง นักเรียน' }
    eventually { expect(URI.parse(current_url).to_s).to have_content 'employees' }
  end

  it 'should see six menu and current page is Payroll' do
    visit "/somsri_payroll#/payroll"
    sleep(1)
    find('#menu').click
    sleep(1)
    eventually { expect(page).to have_content 'เงินเดือน เงินเดือน ค่าเทอม นับแถว บุคลากร ผู้ปกครอง นักเรียน' }
    eventually { expect(URI.parse(current_url).to_s).to have_content 'payroll' }
  end

  it 'should swap report to employees page' do
    visit "/somsri_payroll#/report"
    sleep(1)
    find('#menu').click
    sleep(1)
    find(:xpath, "//a[@href='/somsri_payroll#/employees']").click
    sleep(1)
    find('#menu').click
    sleep(1)
    eventually { expect(page).to have_content 'บุคลากร เงินเดือน ค่าเทอม นับแถว บุคลากร ผู้ปกครอง นักเรียน' }
    eventually { expect(URI.parse(current_url).to_s).to have_content 'employees' }
  end

end
