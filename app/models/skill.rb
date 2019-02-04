class Skill < ApplicationRecord
  has_many :employee_skills, dependent: :destroy
  has_many :employees, through: :employee_skills

  validates :name, uniqueness: { case_sensitive: true }
end
