class CreateExpenseTagItem < ActiveRecord::Migration[5.0]
  def change
    create_table :expense_tag_items do |t|
      t.belongs_to :expense_tag, index: true
      t.belongs_to :expense_item, index: true
    end
  end
end
