class AddUniqKeyForRollCall < ActiveRecord::Migration[5.0]
  def change
    add_index :roll_calls, [:student_id, :list_id, :check_date, :round], :unique => true, :name => 'index_roll_calls_uniq_roll'
  end
end
