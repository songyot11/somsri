class AddDeduceDaysToVacationType < ActiveRecord::Migration[5.0]
  def change
    add_column :vacation_types, :deduce_days, :float
  end
end
