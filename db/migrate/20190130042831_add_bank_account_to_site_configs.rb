class AddBankAccountToSiteConfigs < ActiveRecord::Migration[5.0]
  def change
    add_column :site_configs, :bank_account, :string
  end
end
