class Holiday < ApplicationRecord

  def as_json(options={})
    {
      id: self.id,
      name: self.name,
      start_at: self.start_at.beginning_of_day,
      end_at: self.end_at.end_of_day,
      days: self.days,
      month: I18n.t('date.month_names')[self.start_at.month]
    }
  end

  def days
    if self.start_at.day == self.end_at.day
      self.start_at.day.to_s
    else
      "#{self.start_at.day}-#{self.end_at.day}"
    end
  end
end
