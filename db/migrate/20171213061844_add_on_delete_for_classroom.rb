class AddOnDeleteForClassroom < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :employees, :classrooms
    add_foreign_key :employees, :classrooms, on_delete: :nullify

    remove_foreign_key :students, :classrooms
    add_foreign_key :students, :classrooms, on_delete: :nullify

    add_foreign_key :classrooms, :classrooms, column: :next_id, on_delete: :nullify
  end
end
