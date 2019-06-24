class Candidate < ApplicationRecord
  acts_as_paranoid
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
      link_full_name: helpers.link_to_path(full_name, id),
      nick_name: helpers.link_to_path(nick_name, id),
      school_year: helpers.link_to_path(school_year, id),
      current_ability: helpers.link_to_path(current_ability, id),
      learn_ability: helpers.link_to_path(learn_ability, id),
      email: helpers.link_to_path(email, id),
      from: helpers.link_to_path(from, id),
      created_at: helpers.date_formatter(created_at),
      detail: helpers.link_to_path("รายละเอียด", id)
    }
  end  
end