class CreateVacation < ActiveRecord::Migration[5.0]
  def change
    create_table :vacations do |t|
      t.belongs_to :user
      t.belongs_to :approver
      t.references :vacation_type
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
