describe 'Vacation', js: true do

  let(:user) { user = User.make!({
    email: 'test@mail.com',
    password: '123456789'
  })}

  it 'admin user should see all menu' do
    user.add_role :admin
    login_as(user, scope: :user)

    visit '/somsri#/vacation'
    sleep(1)

    expect(page).to have_content("วันลา")
    expect(page).to have_content("ปฏิทิน")
    expect(page).to have_content("ระเบียบวันลา")
    expect(page).to have_content("ตั้งค่า")
  end

    it 'non admin user should not see setting menu' do
    user.add_role :finance_officer
    login_as(user, scope: :user)

    visit '/somsri#/vacation'
    sleep(1)

    expect(page).to have_content("วันลา")
    expect(page).to have_content("ปฏิทิน")
    expect(page).to have_content("ระเบียบวันลา")
    expect(page).to_not have_content("ตั้งค่า")
  end

end
