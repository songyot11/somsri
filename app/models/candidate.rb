class Candidate < ApplicationRecord
  has_many :programming_skills
  has_many :soft_skills
  has_many :design_skills
  accepts_nested_attributes_for :programming_skills
  accepts_nested_attributes_for :soft_skills
  accepts_nested_attributes_for :design_skills
  
  def helpers
    ApplicationController.helpers
  end  

  def as_json
    return {
      id: id,
      link_full_name: helpers.link_to_full_name(self),
      nick_name: nick_name,
      school_year: school_year,
      current_ability: current_ability,
      learn_ability: learn_ability,
      email: email,
      from: from,
      detail: "<a href = "">รายละเอียด</a> <a href = ""><i class='fa fa-trash'></i><a>"
    }
  end  
end