class Vacation < ApplicationRecord
  enum status: [:pending, :approved, :rejected]

  scope :not_rejected, -> { where(status: ['pending', 'approved']) }
  scope :sick_leave, -> { where(vacation_type: VacationType.where(name: 'ลาป่วย').first) }
  scope :vacation_full_day, -> { where(vacation_type: VacationType.where(name: 'ลากิจ').first) }
  scope :vacation_half_day_morning, -> { where(vacation_type: VacationType.where(name: 'ลากิจครึ่งวันเช้า').first) }
  scope :vacation_half_day_afternoon, -> { where(vacation_type: VacationType.where(name: 'ลากิจครึ่งวันบ่าย').first) }
  scope :switch_date, -> { where(vacation_type: VacationType.where(name: 'สลับวันทำงาน').first) }
  scope :work_at_home, -> { where(vacation_type: VacationType.where(name: 'ทำงานที่บ้าน').first) }
  scope :this_year, -> { where("to_date(start_date, 'DD/MM/YYYY') BETWEEN ? AND ?", Date.today.at_beginning_of_year, Date.today.at_end_of_year) }

  belongs_to :requester, :class_name => "Employee"
  belongs_to :approver, :class_name => "Employee"
  belongs_to :vacation_type

  def deduce_days
    days = (self.end_date.to_date - self.start_date.to_date).to_i + 1
    deduce_days = days * vacation_type.deduce_days
    deduce_days
  end

  def as_json(options={})
    {
      id: self.id,
      detail: self.detail.presence || "",
      status: self.status,
      requester: self.requester&.full_name,
      vacation_type: self.vacation_type,
      start_date: self.start_date,
      end_date: self.end_date,
      start_at: self.start_date.to_date,
      end_at: self.end_date.to_date,
      created_at: self.created_at.strftime('%d/%m/%Y'),
    }
  end
end
