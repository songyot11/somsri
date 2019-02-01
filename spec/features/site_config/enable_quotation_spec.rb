describe 'SiteConfig enable quotation', js: true do
  let(:school) { School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }

  let(:enable_quotation_true) { SiteConfig.make!({ enable_quotation: true }) }
  let(:enable_quotation_false) { SiteConfig.make!({ enable_quotation: false }) }

  before do
    user.add_role :admin
    login_as(user, scope: :user)
  end

  it 'should display quotation in menu' do
    enable_quotation_true
    visit "/"
    sleep(1)
    expect(page).to have_content("วางบิล")
  end

  it 'should not display quotation in menu' do
    enable_quotation_false
    visit "/"
    sleep(1)
    expect(page).to_not have_content("วางบิล")
  end
end
