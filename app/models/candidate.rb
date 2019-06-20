class Candidate < ApplicationRecord
  has_many :programming_skills
  has_many :soft_skills
  has_many :design_skills
  accepts_nested_attributes_for :programming_skills
  accepts_nested_attributes_for :soft_skills
  accepts_nested_attributes_for :design_skills
    
end