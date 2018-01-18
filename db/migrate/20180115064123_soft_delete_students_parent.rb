class SoftDeleteStudentsParent < ActiveRecord::Migration[5.0]
  def change
    add_column :students_parents, :deleted_at, :datetime
    add_index :students_parents, :deleted_at
  end
end
