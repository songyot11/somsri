describe SiteConfigsController do
  let(:site_config) do
    SiteConfig.make!
  end

  let(:admin) do
    user = User.make!
    user.add_role :admin
    user
  end

  before :each do
    site_config
    sign_in admin
  end

  describe '#index' do
    it 'should get all site config' do
      get :index
      data = JSON.parse(response.body)
      expect(data["enable_rollcall"]).to eq(false)
      expect(data["default_cash_payment_method"]).to eq(false)
      expect(data["default_credit_card_payment_method"]).to eq(false)
      expect(data["default_cheque_payment_method"]).to eq(false)
      expect(data["default_transfer_payment_method"]).to eq(false)
      expect(data["display_username_password_on_login"]).to eq(false)
      expect(data["display_schools_year_with_invoice_id"]).to eq(false)
      expect(data["web_cms"]).to eq(false)
      expect(data["tax"]).to eq(true)
      expect(data["student_number_leading_zero"]).to eq(0)
      expect(data["one_slip_per_page"]).to eq(false)
      expect(data["export_ktb_payroll"]).to eq(false)
      expect(data["outstanding_notification"]).to eq(false)
      expect(data["slip_carbon"]).to eq(false)
    end

    it 'should get site config by name' do
      get :index, params: { name: "slip_carbon" }
      expect(response.body).to eq("false")
    end

    it 'should get site config by names' do
      get :index, params: { names: ["slip_carbon", "enable_rollcall", "student_number_leading_zero"] }
      data = JSON.parse(response.body)
      expect(data["slip_carbon"]).to eq(false)
      expect(data["enable_rollcall"]).to eq(false)
      expect(data["student_number_leading_zero"]).to eq(0)
    end
  end
end
