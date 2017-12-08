class CreateAlumni < ActiveRecord::Migration[5.0]
  def change
    create_table :alumnis do |t|
      t.belongs_to :student, index: true
      t.string :name
      t.string :nickname
      t.integer :student_number
      t.string :graduated_year
      t.string :graduated_semester
      t.string :grade
      t.string :classroom
      t.string :status
      t.timestamps
    end
  end
end
