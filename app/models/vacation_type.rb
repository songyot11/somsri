class VacationType < ApplicationRecord
  has_many :vacations

  scope :sick_leave, -> { where(name: 'ลาป่วย').first }
  scope :vacation_full_day, -> { where(name: 'ลากิจ').first }
  scope :vacation_half_day_morning, -> { where(name: 'ลากิจครึ่งวันเช้า').first }
  scope :vacation_half_day_afternoon, -> { where(name: 'ลากิจครึ่งวันบ่าย').first }
  scope :switch_date, -> { where(name: 'สลับวันทำงาน').first }
  scope :work_at_home, -> { where(name: 'ทำงานที่บ้าน').first }
end
