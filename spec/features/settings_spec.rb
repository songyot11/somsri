describe 'Employee Details', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }

  before do
    login_as(user, scope: :user)
  end

  it 'should update edit user detail' do
    visit "/#/setting"
    sleep(1)
    page.fill_in 'ชื่อ', :with => 'Akiyama Eve'
    page.fill_in 'อีเมล', :with => 'akiyama@eve.com'
    click_button('บันทึก')
    sleep(1)

    visit "/#/setting"
    expect(find_field('ชื่อ').value).to eq 'Akiyama Eve'
    expect(find_field('อีเมล').value).to eq 'akiyama@eve.com'
  end

  it 'should update password' do
    visit "/#/setting"
    sleep(1)
    click_button('เปลี่ยนรหัสผ่าน')
    sleep(1)
    page.fill_in 'รหัสผ่านเก่า', :with => 'password'
    page.fill_in 'รหัสผ่านใหม่', :with => 'valid_password'
    first('.modal-body .btn-submit').click
    sleep(1)

    logout(:user)
    visit "/"
    page.fill_in 'Email', :with => user.email
    page.fill_in 'Password', :with => 'valid_password'
    click_button('Log in')
    expect(page).to have_css('.main-menu')
  end
end
