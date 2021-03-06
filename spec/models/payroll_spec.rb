describe Payroll do
  let(:site_configs) { SiteConfig.make!({ tax: true }) }
  let(:school) {school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" })}
  let(:school2) {School.make!({ name: "โรงเรียนแห่ง2" })}
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
      salary: 50000,
      pay_pvf: true,
      pay_social_insurance: true

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
      account_number: "5-234-34532-2342",
      salary: 20000
    }
  )}
  let(:employee3) {employee2 = Employee.make!(
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
      account_number: "5-234-34532-2342",
      salary: 20000
    }
  )}

  let(:payrolls) do
    [
      Payroll.update(employee1.payrolls[0].id,
      {
        salary: 1_000_000, tax: 100,
        effective_date: DateTime.new(2016, 12, 1)
      }),
      Payroll.make!({employee_id: employee1.id, salary: 50_000, tax: 100,
                            effective_date: DateTime.new(2016, 11, 1)}),
      Payroll.make!({employee_id: employee2.id, salary: 1_000_000, tax: 100,
                            effective_date: DateTime.new(2016, 11, 1)}),
      Payroll.update(employee2.payrolls[0].id,
      {
        salary: 50_000, tax: 100,
        effective_date: DateTime.new(2016, 12, 1)
      }),
      Payroll.update(employee3.payrolls[0].id,
      {
        salary: 50_000,
        effective_date: DateTime.new(2016, 12, 1)
      })
    ]
  end

  let(:taxrates) do
    [
     Taxrate.make!({order_id: 1, income: 5_000_000, tax: 0.35}),
     Taxrate.make!({order_id: 2, income: 2_000_000, tax: 0.30}),
     Taxrate.make!({order_id: 3, income: 1_000_000, tax: 0.25}),
     Taxrate.make!({order_id: 4, income: 750_000, tax: 0.20}),
     Taxrate.make!({order_id: 5, income: 500_000, tax: 0.15}),
     Taxrate.make!({order_id: 6, income: 300_000, tax: 0.10}),
     Taxrate.make!({order_id: 7, income: 150_000, tax: 0.05})
    ]
  end

  let(:taxs) do
    [
      taxR1 = TaxReduction.make!({ employee_id: employee1.id}).to_json,
      taxR2 = TaxReduction.make!({ employee_id: employee2.id}).to_json,
      taxR3 = TaxReduction.make!({ employee_id: employee3.id, pension_insurance: 300000,
        pension_fund: 0, government_pension_fund: 0, private_teacher_aid_fund: 0, retirement_mutual_fund: 0,
        national_savings_fund: 0, expenses: 60000, no_income_spouse: 60000, father_alimony: 0, mother_alimony: 0,
        spouse_father_alimony: 0, spouse_mother_alimony: 0, cripple_alimony: 0, insurance: 0, child: 0,
        father_insurance: 0, mother_insurance: 0, spouse_father_insurance: 0, spouse_mother_insurance: 0,
        long_term_equity_fund: 100000, social_insurance: 0, double_donation: 0, donation: 0, other: 0,
        spouse_insurance: 0, house_loan_interest: 0}).to_json
    ]
  end

  before do
    user.add_role :admin
    site_configs
    payrolls
    taxrates
    taxs
  end

  it "should return salary" do
    expect(payrolls[0].salary).to eq(1000000.0)
  end

  it "should return pvf" do
    expect(Payroll.generate_pvf(payrolls[0],employee1)).to eq(payrolls[0].salary*0.03)
  end

  it "should return social_insurance" do
    expect(Payroll.generate_social_insurance(payrolls[0],employee1)).to eq(15000*0.05)
  end

  it "should return  tax" do
    expect(Payroll.generate_tax(payrolls[0],employee1)).to be > 0
  end

  it "should return tax 0 for site config tax = false" do
    SiteConfig.stub_chain("get_cache.tax").and_return(false)
    expect(Payroll.generate_tax(payrolls[0],employee1)).to be 0
  end

  it 'should update employee.salary if changed lasted payroll.salary' do
    payrolls[0].salary = 2000
    payrolls[0].save
    payrolls[0].reload
    employee1.reload
    expect(employee1.salary).to eq 2000.00
    expect(payrolls[0].salary).to eq 2000.00
  end

  it 'should not update employee.salary if changed history payroll.salary' do
    payrolls[1].salary = 2000
    payrolls[1].save
    payrolls[1].reload
    employee1.reload
    expect(employee1.salary).to eq 1000000.00
    expect(payrolls[1].salary).to eq 2000.00
  end

end
