namespace :payrolls do
  desc "set all payroll to closed and create new payroll"
  task :migrate_for_new_flow,  [] => :environment do |t, args|
    Payroll.all.update_all(closed: true)
    Employee.all.without_deleted.to_a.each do |employee|
      if employee.lastest_payroll.nil?
        payroll = Payroll.new({
          employee_id: employee.id
        })
      else
        payroll = Payroll.new({
          employee_id: employee.id,
          salary: employee.lastest_payroll.salary,
          position_allowance: employee.lastest_payroll.position_allowance,
          allowance: employee.lastest_payroll.allowance
        })
      end
      payroll.save
    end
  end
end
