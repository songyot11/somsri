class AddDeletedAtToPayrolls < ActiveRecord::Migration[5.0]
  def change
    add_column :payrolls, :deleted_at, :datetime
    add_index :payrolls, :deleted_at
  end
end
