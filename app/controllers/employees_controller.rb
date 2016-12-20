class EmployeesController < ApplicationController
  # GET /employees/:id/slip
  def slip
    employee = Employee.find(params[:id]).as_json("slip")
  employee[:payroll][:fee_orders] = employee[:payroll][:fee_orders]
                                                      .select { |key, value| value[:value] > 0}
  employee[:payroll][:pay_orders] = employee[:payroll][:pay_orders]
                                                      .select { |key, value| value[:value] > 0}

    render json: employee, status: :ok
  end
end
