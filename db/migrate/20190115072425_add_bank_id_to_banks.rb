class AddBankIdToBanks < ActiveRecord::Migration[5.0]
  def change
    add_column :banks, :bank_id, :string
  end
end
