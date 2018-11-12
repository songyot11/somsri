class Vacation < ApplicationRecord
  enum status: [:pending, :approved, :rejected]

  belongs_to :user, :class_name => "User"
  belongs_to :approver, :class_name => "User"
  belongs_to :vacation_type

  def as_json(options={})
    {
      id: self.id,
      detail: self.detail,
      status: self.status,
      vacation_type: self.vacation_type,
      created_at: self.created_at.strftime('%d/%m/%Y'),
    }
  end
end
