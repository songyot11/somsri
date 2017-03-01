class CreateStudentsParents < ActiveRecord::Migration[5.0]
  def change
    create_table :students_parents do |t|
      t.integer :student_id, :null => false
      t.integer :parent_id, :null => false
      t.integer :relationship_id

      t.timestamps
    end
  end
end
