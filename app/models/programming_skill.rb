class ProgrammingSkill < ApplicationRecord

belongs_to :candidate
accepts_nested_attributes_for :candidate
    
end