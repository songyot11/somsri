class Employee < ApplicationRecord
  belongs_to :school
  has_many :payrolls, dependent: :destroy

  scope :active, -> { where(deleted: false ) }

  def full_name
    if !self.first_name_thai.blank? && !self.last_name_thai.blank?
      [self.prefix_thai, self.first_name_thai, self.last_name_thai].join(" ")
    else
      [self.prefix, self.first_name, self.middle_name, self.last_name].join(" ")
    end
  end

  def annual_income_outcome(id)
    employee = Employee.active.find(id)

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
    if options[:slip]
      result = {
        code: format("%05d", self.id),
        prefix: self.prefix,
        name: self.full_name,
        position: self.position,
        account_number: self.account_number,
        annual_income_outcome: self.annual_income_outcome(self.id)
      }

      if options[:month] && options[:year]
        payroll = self.payroll(options[:month].to_i, options[:year].to_i)
        result[:payroll] = payroll.as_json("slip")
        result[:extra_fee] = payroll.extra_fee.to_f
        result[:extra_pay] = payroll.extra_pay.to_f + payroll.salary.to_f
      else
        result[:payroll] = self.payrolls.latest.as_json("slip")
        result[:extra_fee] = self.payrolls.latest.extra_fee.to_f
        result[:extra_pay] = self.payrolls.latest.extra_pay.to_f + self.payrolls.latest.salary.to_f
      end
      return result
    elsif options[:employee_list]
       {
        id: self.id,
        name: self.full_name,
        salary: self.payrolls.latest.salary.to_f,
        extra_fee: self.payrolls.latest.extra_fee.to_f,
        extra_pay: self.payrolls.latest.extra_pay.to_f,
        img: self.img_url
      }
    else
      super()
    end
  end

  def lastest_payroll
     Payroll.where({ employee_id: self.id }).order(created_at: :desc).first
  end

  def payroll(month, year)
    start_month = Date.new(year, month, 1)
    end_month = start_month.end_of_month
    Payroll.where(employee_id: self.id, created_at: start_month.beginning_of_day..end_month.end_of_day)
                      .order(created_at: :desc)
                      .first
  end

end
