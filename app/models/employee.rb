class Employee < ApplicationRecord
  belongs_to :school
  has_many :emergency_calls, class_name: "Individual", foreign_key: 'emergency_call_id'
  has_many :spouses, class_name: "Individual", foreign_key: 'spouse_id'
  has_many :childs, class_name: "Individual", foreign_key: 'child_id'
  has_many :parents, class_name: "Individual", foreign_key: 'parent_id'
  has_many :friends, class_name: "Individual", foreign_key: 'friend_id'
  belongs_to :grade

  has_one :taxReduction

  has_many :payrolls, dependent: :destroy
  after_create :create_tax_reduction
  before_save :update_rollcall_list

  scope :active, -> { where(deleted: false ) }

  @@warned = false
  def update_rollcall_list
    unless @@warned
      puts 'WARNING: please remove this function after rollcall list assignment has been implemented'

      if self.grade && self.classroom
        # add or update list
      else
        # remove list
      end
      @@warned = true
    end
  end

  def full_name
    if !self.first_name_thai.blank? && !self.last_name_thai.blank?
      [self.prefix_thai, self.first_name_thai, self.last_name_thai].join(" ")
    else
      [self.prefix, self.first_name, self.middle_name, self.last_name].join(" ")
    end
  end

  def annual_income_outcome(id)
    employee = Employee.active.find(id)

    year = employee.payrolls.latest.effective_date.year
    start_year = Date.new(year, 1, 1)
    end_year = Date.new(year, 12, 31)

    payrolls = employee.payrolls.where(effective_date: start_year.beginning_of_day..end_year.end_of_day)

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

      # select payroll by payroll_id
      payroll = self.payroll(options[:payroll_id])
      if payroll
        result[:payroll] = payroll.as_json("slip")
        result[:extra_fee] = payroll.extra_fee.to_f
        result[:extra_pay] = payroll.extra_pay.to_f + payroll.salary.to_f
      else
        # default payroll
        result[:payroll] = self.payrolls.latest.as_json("slip")
        result[:extra_fee] = self.payrolls.latest.extra_fee.to_f
        result[:extra_pay] = self.payrolls.latest.extra_pay.to_f + self.payrolls.latest.salary.to_f
      end
      return result
    elsif options[:employee_list]
       {
        id: self.id,
        name: self.full_name,
        salary: self.payrolls.size > 0 ? self.payrolls.latest.salary.to_f : 0,
        extra_fee: self.payrolls.size > 0 ? self.payrolls.latest.extra_fee.to_f : 0,
        extra_pay: self.payrolls.size > 0 ? self.payrolls.latest.extra_pay.to_f : 0,
        img: self.img_url
      }
    else
      super()
    end
  end

  def lastest_payroll
     Payroll.where({ employee_id: self.id }).order(effective_date: :desc).first
  end

  def payroll(payroll_id)
    Payroll.where(employee_id: self.id, id: payroll_id).first
  end

  def tax_reduction
    TaxReduction.where(employee_id: self.id).first
  end

  private
    def create_tax_reduction
      TaxReduction.create(employee_id: self.id)
    end

end
