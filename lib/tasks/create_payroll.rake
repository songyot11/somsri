desc "This task is called by the Heroku scheduler add-on"
namespace "payroll" do
  namespace "generate" do
    task :on,  [:month, :year] => :environment do |t, args|
      create_payroll(args.month, args.year)
    end

    task :now => :environment  do
      create_payroll
    end
  end
end

def create_payroll(month=DateTime.now.month, year=DateTime.now.year)
  puts "Creating payrolls... on month: #{month}, year: #{year}"

  employees = Employee.all
  employees.each do |employee|
    Payroll.transaction do
      employee_previous = employee.payrolls.order("created_at ASC").last || employee.payrolls.new()

      payroll = employee.payrolls.new(
        salary: employee_previous.salary || 0,
        allowance: 0,
        attendance_bonus: 0,
        ot: 0,
        bonus: 0,
        position_allowance: employee_previous.position_allowance || 0,
        extra_etc: 0,
        absence: 0,
        late: 0,
        tax: employee_previous.tax || 0,
        social_insurance: employee_previous.social_insurance || 0,
        fee_etc: 0,
        pvf: employee_previous.pvf || 0,
        advance_payment: 0,
        created_at: DateTime.new(year.to_i, month.to_i, 1)
      )
      if payroll.save
        puts "Created #{payroll}"
      else
        puts "This month and this year have a payroll already."
        puts "Create payrolls is fail"
        return
      end
    end
  end

  puts "Created payrolls successfully"
end
