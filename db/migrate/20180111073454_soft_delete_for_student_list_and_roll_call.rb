class SoftDeleteForStudentListAndRollCall < ActiveRecord::Migration[5.0]
  def change
    add_column :student_lists, :deleted_at, :datetime
    add_index :student_lists, :deleted_at
  end
end
