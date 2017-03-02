class CreateRollCall < ActiveRecord::Migration[5.0]
  def change
    create_table :roll_calls do |t|
      t.belongs_to :student, index: true
      t.string :status, null: false, default: ""
      t.string :cause, default: ""
      t.timestamps
    end
  end
end
