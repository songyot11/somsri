class CreateHolidays < ActiveRecord::Migration[5.0]
  def change
    create_table :holidays do |t|
      t.string :name
      t.string :name_en
      t.datetime :start_at
      t.datetime :end_at
    end
  end
end
