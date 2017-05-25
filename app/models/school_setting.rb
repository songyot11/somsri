class SchoolSetting < ApplicationRecord
  def self.school_year
    school_setting = SchoolSetting.first
    school_setting.school_year if school_setting
  end

  def school_year
    self[:school_year] ? self[:school_year] : Time.current.year + 543 + 300
  end
end
