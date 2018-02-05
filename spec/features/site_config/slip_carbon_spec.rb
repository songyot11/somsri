describe 'SiteConfig Slip Carbon', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }

  let(:slip_carbon_true) { SiteConfig.make!({ slip_carbon: true }) }
  let(:slip_carbon_false) { SiteConfig.make!({ slip_carbon: false }) }

  before do
    user.add_role :admin
    login_as(user, scope: :user)
  end

  it 'should display print carbon slip' do
    slip_carbon_true
    visit "/somsri_payroll#/report"
    sleep(1)
    find("label#print-report-btn").click
    expect(page).to have_content("พิมพ์สลิปเงินเดือนทุกคนแบบคาร์บอน")
  end

  it 'should not display print carbon slip' do
    slip_carbon_false
    visit "/somsri_payroll#/report"
    sleep(1)
    find("label#print-report-btn").click
    expect(page).to_not have_content("พิมพ์สลิปเงินเดือนทุกคนแบบคาร์บอน")
  end

end
