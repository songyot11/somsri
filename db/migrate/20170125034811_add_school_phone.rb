class AddSchoolPhone < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :zip_code, :string
    add_column :schools, :phone, :string
    add_column :schools, :fax, :string
  end
end
