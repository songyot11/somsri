class CreateEmployeeSkills < ActiveRecord::Migration[5.0]
  def change
    create_table :employee_skills do |t|
      t.references :employee, foreign_key: true
      t.references :skill, foreign_key: true
      t.integer :score

      t.timestamps
    end
  end
end
