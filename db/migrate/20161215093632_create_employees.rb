class CreateEmployees < ActiveRecord::Migration[5.0]
  def change
    create_table :employees do |t|
      t.belongs_to :school, index: true
      t.string :first_name, null: false, default: ""
      t.string :last_name, null: false, default: ""
      t.string :middle_name, null: false, default: ""
      t.string :prefix, null: false, default: ""
      t.integer :sex, null: false, default: 0
      t.string :position, default: ""
      t.string :personal_id, default: ""
      t.string :passport_number, default: ""
      t.string :race, default: ""
      t.string :nationality, default: ""
      t.string :bank_name, default: ""
      t.string :bank_branch, default: ""
      t.string :account_number, default: ""
      t.decimal :salary, null: false, default: 0
      t.string :img_url, default: ""
      t.timestamps null: false
    end
  end
end
