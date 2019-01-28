class CreateExpenseTag < ActiveRecord::Migration[5.0]
  def change
    create_table :expense_tags do |t|
      t.string :name
    end
  end
end
