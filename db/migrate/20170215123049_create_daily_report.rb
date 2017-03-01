class CreateDailyReport < ActiveRecord::Migration[5.0]
  def change
    create_table :daily_reports do |t|
      # real income
      t.float :real_start_cash
      t.float :real_cash
      t.float :real_credit_card
      t.float :real_cheque
      t.float :real_tranfers

      # ideal income
      t.float :cash
      t.float :credit_card
      t.float :cheque
      t.float :tranfers

      t.integer :user_id

      t.timestamps
    end
  end
end
