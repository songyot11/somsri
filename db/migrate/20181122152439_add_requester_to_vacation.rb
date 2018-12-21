class AddRequesterToVacation < ActiveRecord::Migration[5.0]
  def change
    add_column :vacations, :requester_id, :integer
    remove_column :vacations, :user_id, :integer
  end
end
