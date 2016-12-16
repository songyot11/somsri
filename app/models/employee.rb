class Employee < ApplicationRecord
  belongs_to :school
  has_many :payrolls, dependent: :destroy

  def full_name
    [self.first_name, self.middle_name, self.last_name].join(" ")
  end
end
