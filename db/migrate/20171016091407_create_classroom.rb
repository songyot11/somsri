class CreateClassroom < ActiveRecord::Migration[5.0]
  def change
    create_table :classrooms do |t|
      t.belongs_to :next, index: true, class_name: "Classroom"
      t.belongs_to :grade, index: true
      t.string :name, null: false, default: ""
      t.timestamps
    end
  end
end
