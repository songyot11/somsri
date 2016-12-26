class Employee < ApplicationRecord
  belongs_to :school
  has_many :payrolls, dependent: :destroy

  def full_name
    if !self.first_name_thai.blank? && !self.last_name_thai.blank?
      [self.prefix_thai, self.first_name_thai, self.last_name_thai].join(" ")
    else
      [self.prefix, self.first_name, self.middle_name, self.last_name].join(" ")
    end
  end

  def annual_income_outcome(id)
    employee = Employee.find(id)

    year = employee.payrolls.latest.created_at.year
    start_year = Date.new(year, 1, 1)
    end_year = Date.new(year, 12, 31)

    payrolls = employee.payrolls.where(created_at: start_year.beginning_of_day..end_year.end_of_day)

    return {
      total_salary: payrolls.as_json("report").inject(0) { 
        |mem, var| mem + var[:salary] + var[:extra_pay] - var[:extra_fee] 
      },
      total_tax: payrolls.sum(:tax),
      total_social_insurance: payrolls.sum(:social_insurance),
      total_aid_fund: payrolls.sum(:pvf)
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
        extra_fee: self.payrolls.latest.extra_fee.to_f,
        extra_pay: self.payrolls.latest.extra_pay.to_f + 
                   self.payrolls.latest.salary.to_f,
        annual_income_outcome: self.annual_income_outcome(self.id),
        payroll: self.payrolls.latest.as_json("slip")
      }
    elsif options["name_lists"]
      {
        id: self.id,
        name: self.full_name,
      }
    else
      super()
    end
  end

  def lastest_payroll
     Payroll.where({ employee_id: self.id }).order(created_at: :desc).first
  end

end
