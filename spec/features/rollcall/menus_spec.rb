describe 'Employee delete', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }
  before do
    user.add_role :admin
    login_as(user, scope: :user)
  end

  it 'should go to rollcall report' do
    visit "/somsri_rollcall#"
    find('#report.menu-btn').click
    sleep(1)
    expect(page).to have_css("#rollcall-report")
  end

end
