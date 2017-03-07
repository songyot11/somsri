class School < ApplicationRecord
  has_many :employees, dependent: :destroy
  has_many :users
end
