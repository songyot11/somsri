class EmployeeSkill < ApplicationRecord
  belongs_to :employee
  belongs_to :skill

  def as_json(options = {})
    super().merge({
      skill_name: skill.name,
    })
  end
end
