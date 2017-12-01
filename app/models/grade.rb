class Grade < ApplicationRecord
  has_many :classrooms
  def self.names
    Grade.all.collect do |g|
      {value: g.name}
    end
  end

end
