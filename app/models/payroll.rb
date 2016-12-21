class Payroll < ApplicationRecord
  belongs_to :employee

  def extra_fee
    absence + late + tax + social_insurance + fee_etc + pvf + advance_payment
  end

  def extra_pay
    allowance + attendance_bonus + ot + bonus + position_allowance + extra_etc
  end

  def as_json(options={})
    if options["report"]
      {
        code: self.employee.id,
        prefix: self.employee.prefix,
        name: self.employee.full_name,
        account_number: self.employee.account_number,
        salary: self.salary.to_f,
        extra_pay: extra_pay.to_f,
        extra_fee: extra_fee.to_f,
        img_url: self.employee.img_url,
      }
    elsif options["slip"]
      {
        date: self.created_at.strftime("#{created_at.end_of_month.day}/%m/#{(created_at.year + 543) % 100}"),
        pay_orders: {
          salary: {
            name: """
            #{I18n.t('activerecord.attributes.payroll.salary') }
            #{I18n.l(self.created_at, format: "%b")}
            #{(self.created_at.year + 543) % 100}
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
