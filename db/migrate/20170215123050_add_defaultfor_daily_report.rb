class AddDefaultforDailyReport < ActiveRecord::Migration[5.0]
  def change
    change_column :daily_reports, :real_start_cash, :float, default: 0
    change_column :daily_reports, :real_cash, :float, default: 0
    change_column :daily_reports, :real_credit_card, :float, default: 0
    change_column :daily_reports, :real_cheque, :float, default: 0
    change_column :daily_reports, :real_tranfers, :float, default: 0

    change_column :daily_reports, :cash, :float, default: 0
    change_column :daily_reports, :credit_card, :float, default: 0
    change_column :daily_reports, :cheque, :float, default: 0
    change_column :daily_reports, :tranfers, :float, default: 0
  end
end
