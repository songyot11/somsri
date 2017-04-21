class MovePinToEmployee < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :classroom
    remove_column :users, :pin
    remove_column :lists, :user_id

    add_column :employees, :pin, :string
    create_table :teacher_attendance_lists do |t|
      t.belongs_to :employee, index: true
      t.belongs_to :list, index: true
    end
  end
end
