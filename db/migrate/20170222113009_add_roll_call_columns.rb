class AddRollCallColumns < ActiveRecord::Migration[5.0]
  def change
    add_column :roll_calls, :round, :string
    add_column :roll_calls, :check_date, :string
    remove_column :roll_calls, :user_id
    add_reference :roll_calls, :list, index: true
    add_foreign_key :roll_calls, :lists
  end
end
