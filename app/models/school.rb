class School < ApplicationRecord
  has_many :employees, dependent: :destroy
end
