class CreateSiteConfig < ActiveRecord::Migration[5.0]
  def change
    create_table :site_configs do |t|
      t.boolean :enable_rollcall, default: true
      t.boolean :default_cash_payment_method, default: true
      t.boolean :default_credit_card_payment_method, default: false
      t.boolean :default_cheque_payment_method, default: false
      t.boolean :default_transfer_payment_method, default: false
      t.boolean :display_username_password_on_login, default: false
    end
  end
end
