class AddEmployeeTypeDefault < ActiveRecord::Migration[5.0]
  def change
    change_column :employees, :employee_type, :string, :default => "ลูกจ้างประจำ", null: false
  end
end
