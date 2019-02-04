class AddCurrentSemesterToSchoolSetting < ActiveRecord::Migration[5.0]
  def change
    rename_column :school_settings, :semester, :semesters
    add_column :school_settings, :current_semester, :string
  end
end
