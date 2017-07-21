class ChangeEffectiveDateToNullable < ActiveRecord::Migration[5.0]
  def change
    change_column :payrolls, :effective_date, :datetime, null: true
  end
end
