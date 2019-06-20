class DesignSkill < ApplicationRecord

  belongs_to :candidates
  accepts_nested_attributes_for :candidates
    
end