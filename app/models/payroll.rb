class Payroll < ApplicationRecord
  include ActiveModel::Dirty
  acts_as_paranoid without_default_scope: true
  belongs_to :employee
  validate :already_payroll_on_month, on: :create
  before_validation :set_created_at
  after_create :set_default_val
  after_save :update_employee_salary

  scope :latest, -> { order("effective_date ASC").last }

  def update_employee_salary
    if self.salary_changed? && self.employee && self.employee.lastest_payroll.id == self.id
      employee.salary = self.salary
      employee.save
    end
  end

  def already_payroll_on_month
    if Payroll.where(employee_id: self.employee_id, effective_date: self.effective_date).count > 0
      errors.add(:effective_date, "This month and this year have a payroll already.")
    end
  end

  def set_created_at
    self.created_at ||= DateTime.now
  end

  def extra_fee
    absence + late + tax + social_insurance + fee_etc + pvf + advance_payment
  end

  def extra_pay
    allowance + attendance_bonus + ot + bonus + position_allowance + extra_etc
  end

  def as_json(options={})
    if options["report"]
      {
        payroll_id: self.id,
        code: self.employee.id,
        prefix: self.employee.prefix,
        name: self.employee.full_name,
        account_number: self.employee.account_number,
        extra_pay: extra_pay.to_f,
        extra_fee: extra_fee.to_f,
        start_date: self.employee.start_date,
        employee_type: self.employee.employee_type,
        # Income
        salary: self.salary.to_f,
        ot: self.ot.to_f,
        position_allowance: self.position_allowance.to_f,
        allowance: self.allowance.to_f,
        attendance_bonus: self.attendance_bonus.to_f,
        bonus: self.bonus.to_f,
        extra_etc: self.extra_etc.to_f,
        # Outcome
        tax: self.tax.to_f,
        social_insurance: self.social_insurance.to_f,
        absence: self.absence.to_f,
        late: self.late.to_f,
        advance_payment: self.advance_payment.to_f,
        fee_etc: self.fee_etc.to_f,
        pvf: self.pvf.to_f,
        #Result
        net_salary: (self.salary + extra_pay - extra_fee).to_f
      }
    elsif options["history"]
      {
        date: I18n.l(self.effective_date, format: "%B #{effective_date.year + 543}"),
        salary: self.salary.to_f,
        extra_pay: extra_pay.to_f,
        extra_fee: extra_fee.to_f,
      }
    elsif options["slip"]
      {
        date: self.effective_date,
        pay_orders: {
          salary: {
            name: """
            #{I18n.t('activerecord.attributes.payroll.salary') }
            #{I18n.l(self.effective_date, format: "%b")}
            #{(self.effective_date.year + 543) % 100}
            """,
            value: self.salary.to_f,
          },
          ot: {
            name: I18n.t('activerecord.attributes.payroll.ot'),
            value: self.ot.to_f,
          },
          position_allowance: {
            name: I18n.t('activerecord.attributes.payroll.position_allowance'),
            value: self.position_allowance.to_f,
          },
          allowance: {
            name: I18n.t('activerecord.attributes.payroll.allowance'),
            value: self.allowance.to_f,
          },
          attendance_bonus: {
            name: I18n.t('activerecord.attributes.payroll.attendance_bonus'),
            value: self.attendance_bonus.to_f,
          },
          bonus: {
            name: I18n.t('activerecord.attributes.payroll.bonus'),
            value: self.bonus.to_f,
          },
          extra_etc: {
            name: I18n.t('activerecord.attributes.payroll.extra_etc'),
            value: self.extra_etc.to_f,
          },
        },
        fee_orders: {
          tax: {
            name: I18n.t('activerecord.attributes.payroll.tax'),
            value: self.tax.to_f,
          },
          social_insurance: {
            name: I18n.t('activerecord.attributes.payroll.social_insurance'),
            value: self.social_insurance.to_f,
          },
          absence: {
            name: I18n.t('activerecord.attributes.payroll.absence'),
            value: self.absence.to_f,
          },
          late: {
            name: I18n.t('activerecord.attributes.payroll.late'),
            value: self.late.to_f,
          },

          advance_payment: {
            name: I18n.t('activerecord.attributes.payroll.advance_payment'),
            value: self.advance_payment.to_f,
          },
          fee_etc: {
            name: I18n.t('activerecord.attributes.payroll.fee_etc'),
            value: self.fee_etc.to_f,
          },
          pvf: {
            name: I18n.t('activerecord.attributes.payroll.pvf'),
            value: self.pvf.to_f,
          },
        },
      }
    else
      super()
    end
  end

  private
    def set_default_val
      e = Employee.find(self.employee_id)
      self.tax = Payroll.generate_tax(self, e, e.tax_reduction.to_json)
      self.social_insurance = Payroll.generate_social_insurance(self, e)
      self.pvf = Payroll.generate_pvf(self, e)
      self.save
    end

    def self.assume_year_income(payroll)
      income = (payroll["salary"].to_i + payroll["allowance"].to_i + payroll["attendance_bonus"].to_i + payroll["ot"].to_i + payroll["bonus"].to_i + payroll["position_allowance"].to_i + payroll["extra_etc"].to_i - payroll["absence"].to_i - payroll["late"].to_i - payroll["social_insurance"].to_i)*12
    end

    def self.tax_break(payroll, tax_reduction)
      y_income = assume_year_income(payroll)
      income = y_income
      income -= TaxReduction.income_exemption(income, tax_reduction) if income > 0
      income -= TaxReduction.revenue_reduction(income, tax_reduction) if income > 0
      y_income - income
    end

    def self.generate_income_tax(payroll, employee, tax_reduction)
      y_income = self.assume_year_income(payroll)
      cost_of_income = (0.5*y_income) > 100000 ? 100000:(0.5*y_income)
      income = y_income - cost_of_income - 60000
      taxrates = Taxrate.order(:order_id).map {|tr| [tr.income, tr.tax] }
      yearTax = 0
      taxrates.each do |taxrate|
        if income>taxrate[0]
          yearTax += (income-taxrate[0])*taxrate[1]
          income = taxrate[0]
        end
      end
      (yearTax/12).round(2) # month 1-11
    end

    def self.generate_withholding_tax(payroll)
      ((payroll["salary"].to_i + payroll["allowance"].to_i + payroll["attendance_bonus"].to_i + payroll["ot"].to_i + payroll["bonus"].to_i + payroll["position_allowance"].to_i + payroll["extra_etc"].to_i) * 0.03).round(2)
    end

    def self.generate_pvf(payroll, employee)
      return 0 unless employee["pay_pvf"]
      payroll["salary"].to_i > 15000 ? payroll["salary"].to_i * 0.03 : 15000 * 0.03
    end

    def self.generate_social_insurance(payroll, employee)
      return 0 unless employee["pay_social_insurance"]
      income = payroll["salary"].to_i
      income = 15000 if income > 15000
      income >= 1650 ? (income * 0.05).round : 0
    end

    def self.generate_tax(payroll, employee, tax_reduction)
      if employee["employee_type"]=='ลูกจ้างประจำ'
        tax = self.generate_income_tax(payroll, employee, tax_reduction)
      else
        tax = self.generate_withholding_tax(payroll)
      end
    end
end
