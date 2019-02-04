class StudentList < ApplicationRecord
  belongs_to :list
  belongs_to :student

  acts_as_paranoid
end
