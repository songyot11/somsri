describe 'SiteConfig Outstanding Notification', js: true do
  let(:school) { School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }
  let(:outstanding_notification) { SiteConfig.make!({ outstanding_notification: true }) }
  let(:no_outstanding_notification) { SiteConfig.make!({ outstanding_notification: false }) }

  before do
    user.add_role :admin
    login_as(user, scope: :user)
    school
  end

  it 'should display outstanding notification modal when visiting /' do
    outstanding_notification
    visit "/"
    sleep(1)
    expect(page).to have_content("โปรดตรวจสอบค่าบริการที่ค้างชำระของท่าน")
    find("button", text: "กลับสู่การใช้งาน").click
    sleep(1)
    expect(page).to_not have_content("โปรดตรวจสอบค่าบริการที่ค้างชำระของท่าน")

    # when visit / will display modal again
    visit "/"
    expect(page).to have_content("โปรดตรวจสอบค่าบริการที่ค้างชำระของท่าน")
    find("button", text: "กลับสู่การใช้งาน").click
  end

  it 'should not display outstanding notification modal' do
    no_outstanding_notification
    visit "/"
    sleep(1)
    expect(page).to_not have_content("โปรดตรวจสอบค่าบริการที่ค้างชำระของท่าน")
  end
end
