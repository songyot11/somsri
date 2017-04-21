class TeacherAttendanceList < ApplicationRecord
  belongs_to :list
  belongs_to :employee
end
