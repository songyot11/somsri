describe 'Profile', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }
  let(:student) do
    [
      student1 = Student.make!({
        first_name: 'สมศรี',
        last_name: 'ใบเสร็จ'
      }),
      student2 = Student.make!({
        first_name: 'สมชาย',
        last_name: 'ใบไม่เสร็จ'
      })
    ]
  end
  before do
    user.add_role :admin
    login_as(user, scope: :user)
  end

  it 'should update edit user detail' do
    visit "/main#/profile"
    sleep(1)
    page.fill_in 'username', :with => 'Akiyama Eve'
    page.fill_in 'useremail', :with => 'akiyama@eve.com'
    page.fill_in 'name', :with => 'โรงเรียนแห่งหนึ่ง'
    page.fill_in 'schoolTaxId', :with => '1234567890123'
    page.fill_in 'address', :with => 'สถานที่แห่งหนึ่ง มียุงชุกชุม'
    page.fill_in 'zipcode', :with => '50000'
    page.fill_in 'emailSchool', :with => 'mail@mail.com'
    page.fill_in 'phone', :with => '050999999'
    page.fill_in 'fax', :with => '050999999(2)'
    click_button('บันทึก')
    sleep(1)

    visit "/main#/profile"
    sleep(1)
    expect(find_field('username').value).to eq 'Akiyama Eve'
    expect(find_field('useremail').value).to eq 'akiyama@eve.com'
    expect(find_field('name').value).to eq 'โรงเรียนแห่งหนึ่ง'
    expect(find_field('schoolTaxId').value).to eq '1234567890123'
    expect(find_field('address').value).to eq 'สถานที่แห่งหนึ่ง มียุงชุกชุม'
    expect(find_field('zipcode').value).to eq '50000'
    expect(find_field('emailSchool').value).to eq 'mail@mail.com'
    expect(find_field('phone').value).to eq '050999999'
    expect(find_field('fax').value).to eq '050999999(2)'

  end

  it 'should update password' do
    visit "/main#/profile"
    sleep(1)
    click_button('เปลี่ยนรหัสผ่าน')
    sleep(1)
    page.fill_in 'รหัสผ่านเก่า', :with => 'password'
    page.fill_in 'รหัสผ่านใหม่', :with => 'valid_password'
    page.fill_in 'ยืนยันรหัสผ่านใหม่', :with => 'valid_password'
    first('.modal-body .btn-submit').click
    sleep(1)

    logout(:user)
    visit "/"
    find('#user_email').set(user.email)
    find('#user_password').set('valid_password')
    click_button('Sign in')
    visit "/somsri_payroll#"
    expect(page).to have_css('.main-menu')
  end

  it 'should go to setting page' do
    visit "/"
    sleep(1)
    first('a[class="nav-user avatar"]').trigger('click')
    sleep(1)
    find('a[href="/main#/profile"]').trigger('click')
    sleep(1)
    expect(page).to have_content('เปลี่ยนรหัสผ่าน')
    expect(page).to have_content('บันทึก')
    expect(page).to have_content('ยกเลิก')

    visit "/somsri_payroll#/"
    sleep(1)
    first('a[class="nav-user avatar"]').trigger('click')
    sleep(1)
    find('a[href="/main#/profile"]').trigger('click')
    sleep(1)
    expect(page).to have_content('เปลี่ยนรหัสผ่าน')
    expect(page).to have_content('บันทึก')
    expect(page).to have_content('ยกเลิก')

    visit "/somsri_invoice#/"
    sleep(1)
    first('a[class="nav-user avatar"]').trigger('click')
    sleep(1)
    find('a[href="/main#/profile"]').trigger('click')
    sleep(1)
    expect(page).to have_content('เปลี่ยนรหัสผ่าน')
    expect(page).to have_content('บันทึก')
    expect(page).to have_content('ยกเลิก')

    visit "/somsri_rollcall#/"
    sleep(1)
    first('a[class="nav-user avatar"]').trigger('click')
    sleep(1)
    find('a[href="/main#/profile"]').trigger('click')
    sleep(1)
    expect(page).to have_content('เปลี่ยนรหัสผ่าน')
    expect(page).to have_content('บันทึก')
    expect(page).to have_content('ยกเลิก')

    visit "/students"
    sleep(1)
    first('a[class="nav-user avatar"]').trigger('click')
    sleep(1)
    find('a[href="/main#/profile"]').trigger('click')
    sleep(1)
    eventually { expect(page).to have_content('เปลี่ยนรหัสผ่าน') }
    eventually { expect(page).to have_content('บันทึก') }
    eventually { expect(page).to have_content('ยกเลิก') }
  end
end
