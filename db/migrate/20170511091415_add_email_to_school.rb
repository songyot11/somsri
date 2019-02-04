class AddEmailToSchool < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :email, :string
  end
end
