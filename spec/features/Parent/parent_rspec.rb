describe 'Invoice-Report', js: true do

  let(:user) { user = User.create!({
    email: 'test@mail.com',
    password: '123456789'
  })}

  let(:parent) do
    [
      parent1 = Parent.make!({
        full_name: 'สมศรี ใบเสร็จ'
      }),
      parent2 = Parent.make!({
        full_name: 'สมหมาย ใบไม่เสร็จ'
      })
    ]
  end
  let(:invoice) { inv1 = Invoice.make!({
    parent_id: parent[1].id,
    invoice_status_id: 1
  })}

  before do
    user.add_role :admin
    login_as(user, scope: :user)
    parent
    invoice
  end

  it 'should access to parent page' do
    visit '/parents#/'

    eventually { expect(page).to have_content("ผู้ปกครอง") }
  end

  it 'should archive parent' do
    visit '/parents#/'
    sleep(1)
    first('#parent_archive').click
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
    first('#parent_archive').click
    sleep(1)
    page.accept_alert
    sleep(1)
    first('#parent_restore').click
    sleep(1)

    eventually { expect(page).to have_no_content("ผู้ปกครองถูกนำออกจากระบบชั่วคราว") }
  end

  it 'should delete parent' do
    visit '/parents#/'
    sleep(1)
    eventually { expect(page).to have_content("สมศรี ใบเสร็จ") }
    sleep(1)
    first('#parent_delete').click
    sleep(1)

    eventually { expect(page).to have_no_content("สมศรี ใบเสร็จ") }
  end

  it 'should can not destroy parent' do
    visit "/parents/#{parent[1].id}"
    sleep(1)
    eventually { expect(page).to have_no_content("Destroy") }
  end

end
