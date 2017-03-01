class Payroll < ApplicationRecord
  belongs_to :employee
  validate :already_payroll_on_month, on: :create
  before_validation :set_created_at

  scope :latest, -> { order("effective_date ASC").last }

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

  def generate_pvf
    salary > 15000 ? salary * 0.03 : 15000 * 0.03
  end

  def generate_social_insurance
    income = salary + position_allowance - late - absence
    income = 15000 if income > 15000
    income >= 1650 ? (income * 0.05).round : 0
  end

  def generate_income_tax
    income = self.employee.year_income - self.employee.tax_break
    taxrates = Taxrate.order(:order_id).map {|t| [t.income, t.tax] }
    yearTax = 0
    taxrates.each do |taxrate|
      if income>taxrate[0]
        yearTax += (income-taxrate[0])*taxrate[1]
        income = taxrate[0]
      end
    end
    (yearTax/12).round(2) # month 1-11
  end

  def generate_withholding_tax
    (salary + allowance + attendance_bonus + ot + bonus + position_allowance) * 0.03
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
end
