class AddStartEndDateToVacations < ActiveRecord::Migration[5.0]
  def change
    add_column :vacations, :start_date, :string
    add_column :vacations, :end_date, :string
  end
end
