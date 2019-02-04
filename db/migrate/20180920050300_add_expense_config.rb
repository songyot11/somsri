class AddExpenseConfig < ActiveRecord::Migration[5.0]
  def change
    add_column :site_configs, :enable_expenses, :boolean, default: false
  end
end
