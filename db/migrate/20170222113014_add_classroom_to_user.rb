class AddClassroomToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :classroom, :string
  end
end
