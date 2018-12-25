class VacationLeaveRule < ApplicationRecord
  belongs_to :updated_by, :class_name => "User"

  def as_json(options={})
    {
      id: self.id,
      updated_by: self.updated_by&.email,
      message: self.message,
      created_at: self.created_at.strftime('%d/%m/%Y'),
      updated_at: self.updated_at.strftime('%d/%m/%Y')
    }
  end
end
