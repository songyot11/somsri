class CreateEmployeesRoles < ActiveRecord::Migration[5.0]
  def change
    create_table(:employees_roles, :id => false) do |t|
      t.references :employee
      t.references :role
    end

    add_index(:employees_roles, [ :employee_id, :role_id ])
  end
end
