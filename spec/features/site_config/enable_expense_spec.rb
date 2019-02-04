describe 'SiteConfig enable expense', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }

  let(:enable_expenses_true) { SiteConfig.make!({ enable_expenses: true }) }
  let(:enable_expenses_false) { SiteConfig.make!({ enable_expenses: false }) }

  before do
    user.add_role :admin
    login_as(user, scope: :user)
  end

  it 'should display expense tag setting in menu' do
    enable_expenses_true
    visit "/main#/setting"
    sleep(1)
    expect(page).to have_content("ตั้งค่าประเภทค่าใช้จ่าย")
  end

  it 'should not display expense tag setting in menu' do
    enable_expenses_false
    visit "/main#/setting"
    sleep(1)
    expect(page).to_not have_content("ตั้งค่าแท็กค่าใช้จ่าย")
  end

  it 'should display expense in menu' do
    enable_expenses_true
    visit "/"
    sleep(1)
    expect(page).to have_content("บันทึกค่าใช้จ่าย")
  end

  it 'should not display expense in menu' do
    enable_expenses_false
    visit "/"
    sleep(1)
    expect(page).to_not have_content("บันทึกค่าใช้จ่าย")
  end

end
