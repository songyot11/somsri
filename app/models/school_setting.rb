class SchoolSetting < ApplicationRecord
  def self.school_year
    school_setting = SchoolSetting.first
    school_setting ? school_setting.school_year : Time.current.year + 543
  end

  def school_year
    self[:school_year] ? self[:school_year] : Time.current.year + 543
  end

  def self.school_year_or_default(default)
    school_setting = SchoolSetting.first
    school_setting ? school_setting.school_year_or_default(default) : default
  end

  def school_year_or_default(default)
    self[:school_year] ? self[:school_year] : default
  end
end
