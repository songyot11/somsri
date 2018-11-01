class AddTagDescription < ActiveRecord::Migration[5.0]
  def change
    add_column :expense_tags, :description, :string
  end
end
