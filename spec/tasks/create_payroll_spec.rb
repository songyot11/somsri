describe 'create payroll rake task' do
  let(:school) {school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" })}
  let(:employee1) {employee1 = Employee.make!(
    {     
      school_id: school.id,
      first_name: "สมศรี",
      last_name: "เป็นชื่อแอพ",
      prefix: "นาง",
      sex: 1,
      account_number: "5-234-34532-2342",
      salary: 50000
    }
  )}
  let(:employee2) {employee2 = Employee.make!(
    {     
      school_id: school.id,
      first_name: "สมจิตร",
      last_name: "เป็นนักมวย",
      prefix: "นาย",
      sex: 1,
      account_number: "5-234-34532-2342",
      salary: 50000
    }
  )}
  let(:payrolls) do
    [
      pr1 = Payroll.make!({
        employee_id: employee1.id,
        salary: 25_000,
        allowance: 2_500, 
        tax: 968,
        social_insurance: 750, 
        late: 500,
        pvf: 100,
        created_at: DateTime.now()
      }),
      pr2 = Payroll.make!({
        employee_id: employee2.id,
        salary: 25_000,
        allowance: 2_500, 
        tax: 968,
        social_insurance: 750, 
        late: 500,
        pvf: 1000,
        created_at: DateTime.now()
      }),
    ]
  end

  before do
    load File.expand_path(Rails.root + "lib/tasks/create_payroll.rake", __FILE__)
    Rake::Task.define_task(:environment)
  end

  it "should create payroll by payroll:generate:now" do
    employee1
    employee2

    task = Rake::Task["payroll:generate:now"]
    
    expect{ task.invoke }.to change{ Payroll.count }.by(2)
  end

  it "should create payroll by payroll:generate:on" do
    payrolls

    task = Rake::Task["payroll:generate:on"]

    expect{ task.invoke(month=1, year=2017) }.to change{ Payroll.count }.by(2)
  end

  it "should not create payroll by payroll:generate:now" do
    payrolls

    task = Rake::Task["payroll:generate:now"]

    expect{ task.invoke }.to change{ Payroll.count }.by(0)
  end
end