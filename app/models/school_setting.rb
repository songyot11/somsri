class SchoolSetting < ApplicationRecord
  @@default_semesters = ["1","2","3"]

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

  def self.semesters
    school_setting = SchoolSetting.first
    school_setting ? school_setting.semesters : @@default_semesters
  end

  def semesters
    school_setting = SchoolSetting.first
    self[:semesters] ? self[:semesters].split(",") : @@default_semesters
  end

  def self.current_semester
    school_setting = SchoolSetting.first
    school_setting ? school_setting.current_semester : @@default_semesters[0]
  end

  def current_semester
    school_setting = SchoolSetting.first
    self[:current_semester] ? self[:current_semester] : school_setting.semesters[0]
  end
end
