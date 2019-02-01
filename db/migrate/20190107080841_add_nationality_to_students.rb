class AddNationalityToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :nationality, :string
  end
end
