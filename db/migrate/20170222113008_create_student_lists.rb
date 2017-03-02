class CreateStudentLists < ActiveRecord::Migration[5.0]
  def change
    create_table :student_lists do |t|
      t.belongs_to :student, index: true
      t.belongs_to :list, index: true
      t.timestamps
    end
  end
end
