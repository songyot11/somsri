class CreateDesignSkill < ActiveRecord::Migration[5.0]
  def change
    create_table :design_skills do |t|
      t.string :skill_name
      t.integer :skill_point
    end
  end
end
