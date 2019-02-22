class AddNoteAndCommentToEmployee < ActiveRecord::Migration[5.0]
  def change
  	add_column :employees, :note, :string
  	add_column :employees, :comment, :string
  end
end
