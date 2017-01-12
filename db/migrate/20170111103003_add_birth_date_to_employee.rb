class AddBirthDateToEmployee < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :birthdate, :datetime
  end
end
