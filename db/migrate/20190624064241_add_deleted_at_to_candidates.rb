class AddDeletedAtToCandidates < ActiveRecord::Migration[5.0]
  def change
    add_column :candidates, :deleted_at, :datetime
    add_index :candidates, :deleted_at
  end
end
