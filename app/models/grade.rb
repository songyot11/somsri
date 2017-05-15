class Grade < ApplicationRecord

  def self.names
    Grade.all.collect do |g|
      {value: g.name}
    end
  end

end
