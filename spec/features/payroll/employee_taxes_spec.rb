describe 'Taxes', js: true do
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
    [
      pr1 = Payroll.make!({employee_id: employee1.id, salary: 50_000,
                            effective_date: DateTime.new(2016, 12, 1)}),
      pr2 = Payroll.make!({employee_id: employee2.id, salary: 1_000_000,
                            effective_date: DateTime.new(2016, 12, 1)})
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

  before do
    employee1
    employee2
    payrolls
    taxs
    login_as(user, scope: :user)
    taxrates
  end

  it "should return income_exemption 1" do
    expect(TaxReduction.income_exemption(payrolls[0].salary*12, taxs[0])).to eq(90000.0)
  end

  it "should return revenue_reduction 1" do
    expect(TaxReduction.revenue_reduction(payrolls[0].salary*12, taxs[0])).to eq(270000.0)
  end

  it "should return tax 1" do
    expect(Payroll.generate_tax(payrolls[0], employee1, taxs[0])).to eq(1500.0)
  end

  it "should return pvf 1" do
    expect(Payroll.generate_pvf(payrolls[0], employee1)).to eq(0.0)
  end

  it "should return social_insurance 1" do
    expect(Payroll.generate_social_insurance(payrolls[1], employee1)).to eq(0.0)
  end

  it "should return income_exemption 2" do
    expect(TaxReduction.income_exemption(payrolls[1].salary*12, taxs[1])).to eq(0.0)
  end

  it "should return revenue_reduction 2" do
    expect(TaxReduction.revenue_reduction(payrolls[1].salary*12, taxs[1])).to eq(120000.0)
  end

  it "should return tax 2" do
    expect(Payroll.generate_tax(payrolls[1], employee2, taxs[1])).to eq(306083.33)
  end

  it "should return pvf 2" do
    expect(Payroll.generate_pvf(payrolls[1], employee2)).to eq(30000.0)
  end

  it "should return social_insurance 2" do
    expect(Payroll.generate_social_insurance(payrolls[1], employee2)).to eq(750.0)
  end
end