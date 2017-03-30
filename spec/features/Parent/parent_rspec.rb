describe 'Invoice-Report', js: true do

  let(:user) { user = User.create!({
    email: 'test@mail.com',
    password: '123456789'
  })}

  let(:parent) do
    [
      parent1 = Parent.make!({
        full_name: 'สมศรี ใบเสร็จ'
      })
    ]
  end

  before do
    user.add_role :admin
    login_as(user, scope: :user)
    parent
  end

  it 'should access to parent page' do
    visit '/parents#/'

    eventually { expect(page).to have_content("ผู้ปกครอง") }
  end

  it 'should archive parent' do
    visit '/parents#/'
    sleep(1)
    find('#parent_archive').click
    sleep(1)
    page.accept_alert
    sleep(1)
    parent[0].reload
    sleep(1)

    eventually { expect(page).to have_content("ผู้ปกครองถูกนำออกจากระบบชั่วคราว") }
    eventually { expect(parent[0].deleted_at).to_not eq(nil) }
  end

  it 'should restore parent' do
    visit '/parents#/'
    find('#parent_archive').click
    sleep(1)
    page.accept_alert
    sleep(1)
    find('#parent_restore').click
    sleep(1)

    eventually { expect(page).to have_no_content("ผู้ปกครองถูกนำออกจากระบบชั่วคราว") }
  end

  it 'should delete parent' do
    visit '/parents#/'
    sleep(1)
    eventually { expect(page).to have_content("สมศรี ใบเสร็จ") }
    sleep(1)
    find('#parent_delete').click
    sleep(1)

    eventually { expect(page).to have_no_content("สมศรี ใบเสร็จ") }
  end
end
