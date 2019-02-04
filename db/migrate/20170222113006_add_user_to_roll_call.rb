class AddUserToRollCall < ActiveRecord::Migration[5.0]
  def change
    add_reference :roll_calls, :user, index: true
    add_foreign_key :roll_calls, :users
  end
end
