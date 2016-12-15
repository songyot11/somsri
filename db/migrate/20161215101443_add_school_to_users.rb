class AddSchoolToUsers < ActiveRecord::Migration[5.0]
  def change
    add_reference :users, :school, index: true
    add_foreign_key :users, :schools
  end
end
