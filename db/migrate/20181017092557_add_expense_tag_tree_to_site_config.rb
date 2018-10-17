class AddExpenseTagTreeToSiteConfig < ActiveRecord::Migration[5.0]
  def change
    add_column :site_configs, :expense_tag_tree, :string
  end
end
