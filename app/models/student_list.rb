class StudentList < ApplicationRecord
  belongs_to :list
  belongs_to :student
end
