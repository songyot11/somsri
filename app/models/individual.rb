class Individual < ApplicationRecord
  def full_name
    if !self.first_name_thai.blank? && !self.last_name_thai.blank?
      [self.prefix_thai, self.first_name_thai, self.last_name_thai].join(" ")
    else
      [self.prefix, self.first_name, self.middle_name, self.last_name].join(" ")
    end
  end

  def as_json(options={})
    if options[:full_name]
      result = super()
      result["full_name"] = self.full_name
      return result
    else
      super()
    end
  end
end
