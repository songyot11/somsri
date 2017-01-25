class AddTaxFlagsToEmployees < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :pay_social_insurance, :boolean
    add_column :employees, :pay_pvf, :boolean
  end
end
