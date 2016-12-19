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
    else
      super()
    end
  end
end
