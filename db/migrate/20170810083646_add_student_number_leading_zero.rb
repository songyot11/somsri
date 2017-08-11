class AddStudentNumberLeadingZero < ActiveRecord::Migration[5.0]
  def change
    add_column :site_configs, :student_number_leading_zero, :integer, default: 0
  end
end
