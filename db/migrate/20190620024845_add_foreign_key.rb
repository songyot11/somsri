class AddForeignKey < ActiveRecord::Migration[5.0]
  def change
    add_reference :programming_skills, :candidate, foreign_key: { to_table: :candidates }
    add_reference :soft_skills, :candidate, foreign_key: { to_table: :candidates }
    add_reference :design_skills, :candidate, foreign_key: { to_table: :candidates }
  end
end
