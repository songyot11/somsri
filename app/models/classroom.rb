class Classroom < ApplicationRecord
  belongs_to :grade
  has_many :students
end
