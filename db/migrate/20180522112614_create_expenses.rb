class CreateExpenses < ActiveRecord::Migration[5.0]
  def change
    create_table :expenses do |t|
      t.datetime :effective_date
      t.string :expenses_id
      t.string :detail
      t.timestamps
    end
  end
end
