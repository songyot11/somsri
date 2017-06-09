class AddSemesterToSchoolSetting < ActiveRecord::Migration[5.0]
  def change
    add_column :school_settings, :semester, :string
  end
end
