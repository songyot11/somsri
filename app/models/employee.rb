class Employee < ApplicationRecord
  belongs_to :school
  has_many :payrolls, dependent: :destroy
end
