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
      salary: 50000
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
      salary: 20000
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
        pension_fund: 0, expenses: 60000, no_income_spouse: 60000, child: 0, father_alimony: 0, mother_alimony: 0,
        spouse_father_alimony: 0, spouse_mother_alimony: 0, cripple_alimony: 0, insurance: 0, spouse_insurance: 0,
        father_insurance: 0, mother_insurance: 0, spouse_father_insurance: 0, spouse_mother_insurance: 0,
        long_term_equity_fund: 100000, social_insurance: 0, double_donation: 0, donation: 0, other: 0}),

      taxR2 = TaxReduction.make!({ employee_id: employee2.id, pension_insurance: 300000, 
        pension_fund: 300000, government_pension_fund: 300000, private_teacher_aid_fund: 300000,
        retirement_mutual_fund: 300000, national_savings_fund: 300000, expenses: 50000 })
    ]
  end

  before do
    employee1
    employee2
    payrolls
    taxs
    login_as(user, scope: :user)
  end

  it "should return exempt income 1" do
    expect(taxs[0].income_exemption).to eq(90000)
  end

  it "should return exempt income 2" do
    expect(taxs[1].income_exemption).to be <= 500000
  end

  it "should return revenue reduction" do
    expect(taxs[0].revenue_reduction).to eq(196500)
  end

  it "should return year income" do
    expect(employee1.year_income).to be >= 0
  end

  it "should return monthly income" do
    expect(employee1.year_income).to be >= 0
  end
end