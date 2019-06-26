class AddInterestToCandidates < ActiveRecord::Migration[5.0]
  def change
    add_column :candidates, :interest, :string
  end
end
