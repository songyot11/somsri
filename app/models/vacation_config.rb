class VacationConfig < ApplicationRecord
  enum work_at_home_unit: [:week, :month]
end
