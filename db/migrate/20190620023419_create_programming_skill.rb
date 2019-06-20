class CreateProgrammingSkill < ActiveRecord::Migration[5.0]
  def change
    create_table :programming_skills do |t|
      t.string :skill_name
      t.integer :skill_point
    end
  end
end
