class List < ApplicationRecord
  belongs_to :user
  has_many :student_lists, dependent: :destroy
  has_many :roll_calls, dependent: :destroy
  has_many :class_permisions, dependent: :destroy

  def get_students
    students = []
    student_lists = self.student_lists.to_a
    student_ids = student_lists.collect(&:student_id)
    return Student.where({ id: student_ids }).to_a
  end

  def get_roll_calls_by_round(date, round)
    if round && date
      return roll_calls.collect { |rc| rc if rc.round == round && rc.check_date == date }.compact
    elsif round
      return roll_calls.collect { |rc| rc if rc.round == round }.compact
    elsif date
      return roll_calls.collect { |rc| rc if rc.check_date == date }.compact
    else
      return roll_calls
    end
  end

end
