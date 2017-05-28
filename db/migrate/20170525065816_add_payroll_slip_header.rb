class AddPayrollSlipHeader < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :payroll_slip_header, :text
  end
end
