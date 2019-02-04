class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.string :name,          limit: 512, null: false
      t.datetime :date,         null: false
      t.integer :account_type_id,  null: false
      t.float :amount,          default: 0, null: false
      t.string :note,           limit: 1024

      t.timestamps
    end

    add_index :accounts, :name
  end
end
