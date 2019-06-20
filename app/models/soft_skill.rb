class SoftSkill < ApplicationRecord
    
    belongs_to :candidate
    accepts_nested_attributes_for :candidates
end