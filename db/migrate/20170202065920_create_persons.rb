class CreatePersons < ActiveRecord::Migration[5.0]
  def change
    create_table :individuals do |t|
      t.string :prefix
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.string :first_name_thai
      t.string :last_name_thai
      t.string :prefix_thai
      t.string :personal_id
      t.string :passport_number
      t.string :race
      t.string :nationality
      t.string :phone
      t.string :email
      t.string :relationship
      t.datetime :birthdate
      t.timestamps
    end

    add_reference :individuals, :emergency_call, references: :employees, index: true
    add_foreign_key :individuals, :employees, column: :emergency_call_id

    add_reference :individuals, :spouse, references: :employees, index: true
    add_foreign_key :individuals, :employees, column: :spouse_id

    add_reference :individuals, :child, references: :employees, index: true
    add_foreign_key :individuals, :employees, column: :child_id

    add_reference :individuals, :parent, references: :employees, index: true
    add_foreign_key :individuals, :employees, column: :parent_id

    add_reference :individuals, :friend, references: :employees, index: true
    add_foreign_key :individuals, :employees, column: :friend_id

  end
end
