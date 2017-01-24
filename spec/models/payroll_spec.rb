describe Payroll do

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
      account_number: "5-234-34532-2342",
      salary: 20000,
      tax_break: 1000000
    }
  )}

  let(:payrolls) do
    [
      pr1 = Payroll.make!({employee_id: employee1.id, salary: 1_000_000, tax: 100,
                            effective_date: DateTime.new(2016, 12, 1)}),
      pr2 = Payroll.make!({employee_id: employee1.id, salary: 50_000, tax: 100,
                            effective_date: DateTime.new(2016, 11, 1)}),
      pr3 = Payroll.make!({employee_id: employee2.id, salary: 1_000_000, tax: 100,
                            effective_date: DateTime.new(2016, 11, 1)}),
      pr3 = Payroll.make!({employee_id: employee2.id, salary: 50_000, tax: 100,
                            effective_date: DateTime.new(2016, 12, 1)})
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

  before do
    payrolls
    taxrates
  end

  it "should return salary" do
    expect(payrolls[0].salary).to eq(1000000.0)
  end

  it "should return pvf" do
    expect(payrolls[0].generate_pvf).to eq(payrolls[0].salary*0.03)
  end

  it "should return social_insurance" do
    expect(payrolls[0].generate_social_insurance).to eq(15000*0.05)
  end

  it "should return income tax" do
    expect(payrolls[0].generate_income_tax).to eq(309583)
  end

  it "should return income tax2" do
    expect(payrolls[2].generate_income_tax).to eq(280416)
  end

  it "should return withholding tax" do
    expect(payrolls[0].generate_withholding_tax).to eq(payrolls[0].salary*0.03)
  end
end
