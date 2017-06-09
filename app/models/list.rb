class List < ApplicationRecord
  has_many :student_lists, dependent: :destroy
  has_many :roll_calls, dependent: :destroy
  has_many :teacher_attendance_lists, dependent: :destroy

  def get_students
    student_ids = StudentList.where(list_id: self.id).pluck(:student_id).to_a
    return Student.where({ id: student_ids }).to_a
  end

  def get_roll_calls_by_round(date, round)
    _result = []
    _student_ids = self.roll_calls.collect {|rc| rc.student_id}
    _students = Student.where(id: _student_ids).to_a

    if round && date
      return self.roll_calls.collect {|rc| rc.merge_classroom_number(_students) if rc.round == round && rc.check_date == date }.compact
    elsif round
      return self.roll_calls.collect {|rc| rc.merge_classroom_number(_students) if rc.round == round}.compact
    elsif date
      return self.roll_calls.collect {|rc| rc.merge_classroom_number(_students) if rc.check_date == date}.compact
    else
      return self.roll_calls.collect {|rc| rc.merge_classroom_number(_students) }
    end
  end

end
