class CreateVacationConfig < ActiveRecord::Migration[5.0]
  def change
    create_table :vacation_configs do |t|
      t.integer :vacation_leave_advance_at_least, default: 0
      t.integer :switch_date_advance_at_least, default: 0
      t.integer :work_at_home_unit, default: 0
      t.integer :work_at_home_limit, default: 0
      t.boolean :can_leave_half_day, default: true
    end
  end
end
