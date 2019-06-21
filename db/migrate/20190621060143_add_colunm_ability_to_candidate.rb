class AddColunmAbilityToCandidate < ActiveRecord::Migration[5.0]
  def change
    add_column :candidates, :current_ability, :integer
    add_column :candidates, :learn_ability, :integer
    add_column :candidates, :attention , :integer
  end
end
