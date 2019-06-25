class AddShortlistToCandidates < ActiveRecord::Migration[5.0]
  def change
    add_column :candidates, :shortlist , :boolean, default: false
  end
end
