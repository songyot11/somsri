describe 'SiteConfig Calculate Tax', js: true do
  let(:enable_tax) { SiteConfig.make!({ tax: true }) }
  let(:disable_tax) { SiteConfig.make!({ tax: false }) }
  let(:school) {school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" })}
  let(:user) { User.make!({ school_id: school.id }) }
  let(:employee1) {employee1 = Employee.make!(
    {
      school_id: school.id,
      first_name: "Somsri",
      middle_name: "Is",
      last_name: "Appname",
      prefix: "Mrs.",
      first_name_thai: "สมศรี",
      last_name_thai: "เป็นชื่อแอพ",
      prefix_thai: "นาง",
      sex: 1,
      account_number: "5-234-34532-2342",
      employee_type: "ลูกจ้างรายวัน"
    }
  )}
  let(:employee2) {employee2 = Employee.make!(
    {
      school_id: school.id,
      first_name: "Somchit",
      middle_name: "Is",
      last_name: "Boxing",
      prefix: "Mr",
      first_name_thai: "สมจิตร",
      last_name_thai: "เป็นนักมวย",
      prefix_thai: "นาย",
      sex: 1,
      account_number: "5-234-34532-2341",
      pay_pvf: true,
      pay_social_insurance: true,
      employee_type: "ลูกจ้างประจำ"
    }
  )}

  let(:payrolls) do
    Payroll.where(employee_id: employee1.id).first.update({salary: 50_000, closed: false })
    Payroll.where(employee_id: employee2.id).first.update({salary: 1_000_000, closed: false })
    [
      Payroll.where(employee_id: employee1.id).first,
      Payroll.where(employee_id: employee2.id).first
    ]
  end

  let(:taxs) do
    [
      taxR1 = TaxReduction.make!({ employee_id: employee1.id, pension_insurance: 300000,
        pension_fund: 0, government_pension_fund: 0, private_teacher_aid_fund: 0, retirement_mutual_fund: 0,
        national_savings_fund: 0, expenses: 60000, no_income_spouse: 60000, father_alimony: 0, mother_alimony: 0,
        spouse_father_alimony: 0, spouse_mother_alimony: 0, cripple_alimony: 0, insurance: 0, child: 0,
        father_insurance: 0, mother_insurance: 0, spouse_father_insurance: 0, spouse_mother_insurance: 0,
        long_term_equity_fund: 100000, social_insurance: 0, double_donation: 0, donation: 0, other: 0,
        spouse_insurance: 0, house_loan_interest: 0}).to_json,
      taxR2 = TaxReduction.make!({ employee_id: employee2.id, expenses: 60000 }).to_json
    ]
  end

  let(:taxrates) do
    [
      Taxrate.make!({order_id: "1", income: "5000000", tax: "0.35"}),
      Taxrate.make!({order_id: "2", income: "2000000", tax: "0.30"}),
      Taxrate.make!({order_id: "3", income: "1000000", tax: "0.25"}),
      Taxrate.make!({order_id: "4", income: "750000", tax: "0.20"}),
      Taxrate.make!({order_id: "5", income: "500000", tax: "0.15"}),
      Taxrate.make!({order_id: "6", income: "300000", tax: "0.10"}),
      Taxrate.make!({order_id: "7", income: "150000", tax: "0.05"})
    ]
  end

  describe 'enable tax' do
    before do
      enable_tax
      user.add_role :admin
      employee1
      employee2
      payrolls
      taxs
      login_as(user, scope: :user)
      taxrates
    end

    it 'should calculate tax at payroll' do
      visit "/somsri_payroll#/payroll"
      sleep(1)
      expect(page).to have_content("50,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 1,500.00 0.00 0.00 0.00 0.00 48,500.00")
      expect(page).to have_content("1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 750.00 30,000.00 0.00 0.00 969,250.00")
    end

    it 'should calculate tax at employee detail' do
      visit "/somsri_payroll#/employees/#{employee1.id}"
      sleep(1)
      click_link('เงินเดือน')
      sleep(1)
      eventually { expect(find_field('ภาษีหัก ณ ที่จ่าย', disabled: true).value.to_i).to eq 1500 }
    end
  end

  describe 'disable tax' do
    before do
      disable_tax
      user.add_role :admin
      employee1
      employee2
      payrolls
      taxs
      login_as(user, scope: :user)
      taxrates
    end

    it 'should display 0 tax at payroll' do
      visit "/somsri_payroll#/payroll"
      sleep(1)
      expect(page).to have_content("50,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 50,000.00")
      expect(page).to have_content("1,000,000.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 750.00 30,000.00 0.00 0.00 969,250.00")
    end

    it 'should display 0 tax at employee detail' do
      visit "/somsri_payroll#/employees/#{employee1.id}"
      sleep(1)
      click_link('เงินเดือน')
      sleep(1)
      eventually { expect(find_field('ภาษีหัก ณ ที่จ่าย', disabled: true).value.to_i).to eq 0 }
    end
  end
end
