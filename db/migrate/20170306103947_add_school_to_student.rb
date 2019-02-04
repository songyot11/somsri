class AddSchoolToStudent < ActiveRecord::Migration[5.0]
  def change
    add_reference :students, :school, index: true
    add_foreign_key :students, :schools
  end
end
