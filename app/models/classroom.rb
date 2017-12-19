class Classroom < ApplicationRecord
  belongs_to :grade
  has_many :students, dependent: :nullify
  has_many :employees, dependent: :nullify
  has_one :previous, class_name: "Classroom", foreign_key: 'next_id', dependent: :nullify
end
