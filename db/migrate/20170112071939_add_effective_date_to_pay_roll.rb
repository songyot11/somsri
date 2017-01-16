class AddEffectiveDateToPayRoll < ActiveRecord::Migration[5.0]
  def change
    add_column :payrolls, :effective_date, :datetime, null: false, default: DateTime.now
  end
end
