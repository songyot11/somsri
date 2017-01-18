class AddSchoolDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :tax_id, :string
    add_column :schools, :address, :string
  end
end
