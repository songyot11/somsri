class Employee < ApplicationRecord
  belongs_to :school
  has_many :payrolls, dependent: :destroy

  def full_name
    [self.prefix, self.first_name, self.middle_name, self.last_name].join(" ")
  end

  def annual_income_outcome(id)
    employee = Employee.find(id)

    year = employee.payrolls.order("created_at ASC").last.created_at.year
    start_year = Date.new(year, 1, 1)
    end_year = Date.new(year, 12, 31)

    payrolls = employee.payrolls.where(created_at: start_year.beginning_of_day..end_year.end_of_day)

    return {
      total_salary: payrolls.as_json("report").inject(0) { 
        |mem, var| mem + var[:salary] + var[:extra_pay] - var[:extra_fee] 
      },
      total_tax: payrolls.sum(:tax),
      total_social_insurance: payrolls.sum(:social_insurance)
    }
  end

  def as_json(options={})
    if options["slip"]
      {
        code: format("%05d", self.id),
        prefix: self.prefix,
        name: self.full_name,
        position: self.position,
        account_number: self.account_number,
        extra_fee: self.payrolls.order("created_at ASC").last.extra_fee.to_f,
        extra_pay: self.payrolls.order("created_at ASC").last.extra_pay.to_f + 
                   self.payrolls.order("created_at ASC").last.salary.to_f,
        annual_income_outcome: self.annual_income_outcome(self.id),
        payroll: self.payrolls.order("created_at ASC").last.as_json("slip")
      }
    else
      super()
    end
  end
end
