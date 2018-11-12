class Vacation < ApplicationRecord
  enum status: [:pending, :approved, :rejected]

  belongs_to :user, :class_name => "User"
  belongs_to :approver, :class_name => "User"
  belongs_to :vacation_type
end
