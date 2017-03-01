class CreateStudents < ActiveRecord::Migration[5.0]
  def change
    create_table :students do |t|
      t.string :full_name
      t.string :full_name_english
      t.string :nickname
      t.string :nickname_english
      t.integer :gender_id
      t.datetime :birthdate
      t.integer :grade_id
      t.string :classroom
      t.integer :classroom_number
      t.integer :student_number
      t.string :national_id
      t.text :remark

      t.timestamps
    end
  end
end
