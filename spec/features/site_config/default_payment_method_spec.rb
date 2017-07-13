describe 'SiteConfig Default Payment Method', js: true do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:user) { User.make!({ school_id: school.id }) }

  let(:default_cash_payment_method) { SiteConfig.make!({ default_cash_payment_method: true }) }
  let(:default_credit_card_payment_method) { SiteConfig.make!({ default_credit_card_payment_method: true }) }
  let(:default_cheque_payment_method) { SiteConfig.make!({ default_cheque_payment_method: true }) }
  let(:default_transfer_payment_method) { SiteConfig.make!({ default_transfer_payment_method: true }) }

  before do
    user.add_role :admin
    login_as(user, scope: :user)
  end

  it 'should checked cash option by default' do
    default_cash_payment_method
    visit "/somsri_invoice#/invoice"
    sleep(1)
    expect(find("label", text: "เงินสด").find("input")).to be_checked
    expect(find("label", text: "บัตรเครดิต").find("input")).to_not be_checked
    expect(find("label", text: "เช็คธนาคาร").find("input")).to_not be_checked
    expect(find("label", text: "เงินโอน").find("input")).to_not be_checked
  end

  it 'should checked credit card option by default' do
    default_credit_card_payment_method
    visit "/somsri_invoice#/invoice"
    sleep(1)
    expect(find("label", text: "เงินสด").find("input")).to_not be_checked
    expect(find("label", text: "บัตรเครดิต").find("input")).to be_checked
    expect(find("label", text: "เช็คธนาคาร").find("input")).to_not be_checked
    expect(find("label", text: "เงินโอน").find("input")).to_not be_checked
  end

  it 'should checked transfer option by default' do
    default_transfer_payment_method
    visit "/somsri_invoice#/invoice"
    sleep(1)
    expect(find("label", text: "เงินสด").find("input")).to_not be_checked
    expect(find("label", text: "บัตรเครดิต").find("input")).to_not be_checked
    expect(find("label", text: "เช็คธนาคาร").find("input")).to_not be_checked
    expect(find("label", text: "เงินโอน").find("input")).to be_checked
  end

  it 'should checked cheque option by default' do
    default_cheque_payment_method
    visit "/somsri_invoice#/invoice"
    sleep(1)
    expect(find("label", text: "เงินสด").find("input")).to_not be_checked
    expect(find("label", text: "บัตรเครดิต").find("input")).to_not be_checked
    expect(find("label", text: "เช็คธนาคาร").find("input")).to be_checked
    expect(find("label", text: "เงินโอน").find("input")).to_not be_checked
  end

end
