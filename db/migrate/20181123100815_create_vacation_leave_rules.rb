class CreateVacationLeaveRules < ActiveRecord::Migration[5.0]
  def change
    create_table :vacation_leave_rules do |t|
      t.text :message
      t.references :updated_by
      t.timestamps
    end
  end
end
