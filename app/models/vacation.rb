class Vacation < ApplicationRecord
  enum status: [:pending, :approved, :rejected]

  scope :not_approved, -> { where(status: ['pending', 'rejected']) }
  scope :sick_leave, -> { where(vacation_type: VacationType.where(name: 'ลาป่วย').first) }
  scope :vacation_full_day, -> { where(vacation_type: VacationType.where(name: 'ลากิจ').first) }
  scope :vacation_half_day_morning, -> { where(vacation_type: VacationType.where(name: 'ลากิจครึ่งวันเช้า').first) }
  scope :vacation_half_day_afternoon, -> { where(vacation_type: VacationType.where(name: 'ลากิจครึ่งวันบ่าย').first) }
  scope :switch_date, -> { where(vacation_type: VacationType.where(name: 'สลับวันทำงาน').first) }
  scope :work_at_home, -> { where(vacation_type: VacationType.where(name: 'ทำงานที่บ้าน').first) }

  belongs_to :user, :class_name => "User"
  belongs_to :approver, :class_name => "User"
  belongs_to :vacation_type

  def as_json(options={})
    {
      id: self.id,
      detail: self.detail,
      status: self.status,
      vacation_type: self.vacation_type,
      created_at: self.created_at.strftime('%d/%m/%Y'),
    }
  end
end
