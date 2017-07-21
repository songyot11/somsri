describe 'SiteConfig Display Username Password On Login', js: true do
  let(:school) { School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }

  let(:display_username_password_on_login) { SiteConfig.make!({ display_username_password_on_login: true }) }
  let(:not_display_username_password_on_login) { SiteConfig.make!({ display_username_password_on_login: false }) }

  before do
    school
  end

  it 'should display username password on login' do
    display_username_password_on_login
    visit "/"
    sleep(1)
    expect(page).to have_content("ฝ่ายบุคคล User name: admin@bananacoding.com Password: password ฝ่ายการเงิน User name: finance@bananacoding.com Password: password")
  end

  it 'should not display username password on login' do
    not_display_username_password_on_login
    visit "/"
    sleep(1)
    expect(page).to_not have_content("ฝ่ายบุคคล User name: admin@bananacoding.com Password: password ฝ่ายการเงิน User name: finance@bananacoding.com Password: password")
  end
end
