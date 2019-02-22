class CreateBanks < ActiveRecord::Migration[5.0]
  def change
    create_table :banks do |t|
      t.attachment :image
      t.string :bank_name
      t.string :bank_account
      t.string :account_name
      t.timestamps
    end
  end
end
