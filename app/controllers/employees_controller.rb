class EmployeesController < ApplicationController
  load_and_authorize_resource
  skip_before_action :verify_authenticity_token, :only => [:update, :create, :destroy]

  # GET /employees
  def index
    employee = @employees.active.order('employees.start_date ASC, employees.created_at ASC')
                         .as_json("name_lists")
    render json: employee, status: :ok
  end

  # GET /employees/:id/slip
  def slip
    employee = Employee.active.find(params[:id]).as_json("slip")
    employee[:payroll][:fee_orders] = employee[:payroll][:fee_orders]
                                                      .select { |key, value| value[:value] > 0}
    employee[:payroll][:pay_orders] = employee[:payroll][:pay_orders]
                                                      .select { |key, value| value[:value] > 0}

    render json: employee, status: :ok
  end

  # GET /employees/:id
  def show
    @employee = Employee.active.find(params[:id])
    render json: {
      employee: @employee,
      payroll: @employee.lastest_payroll
    }
  end

  def create
    school = current_user.school
    render json: employee.errors, status: 500 and return if !school

    employee = school.employees.new(employee_params)
    if employee.save
      payroll = employee.payrolls.new()
      if payroll.save
        render json: {
          employee: employee,
          payroll: employee.lastest_payroll
        }, status: :ok
      else
        render json: employee.errors, status: 500
      end
    else
      render json: employee.errors, status: 500
    end
  end

  # PATCH /employees/:id
  def update
    employee_datas = employee_params
    employee_datas.delete(:id)
    payroll_datas = payroll_params
    payroll_id = payroll_datas[:id]
    payroll_datas[:salary] = employee_datas[:salary]
    payroll_datas.delete(:id)

    employee = Employee.update(params[:id] , employee_datas)
    payroll = Payroll.update(payroll_id, payroll_datas)

    render json: {
      employee: employee,
      payroll: employee.lastest_payroll
    }
  end

  # DELETE /employees/:id
  def destroy
    @employee.update(deleted: true)

    data = {status: "success"}
    render json: data, status: :ok
  end

  private
  def employee_params
    result = params.require(:employee).permit([
      :id,
      :prefix_thai,
      :first_name_thai,
      :last_name_thai,
      :prefix,
      :first_name,
      :middle_name,
      :last_name,
      :position,
      :personal_id,
      :passport_number,
      :race,
      :nationality,
      :bank_name,
      :bank_branch,
      :account_number,
      :salary,
      :nickname,
      :start_date,
      :img_url
    ]).to_h
    result[:salary] = 0 if result[:salary].blank?
    return result
  end

  def payroll_params
    result = params.require(:payroll).permit([
      :id,
      :employee_id,
      :salary,
      :allowance,
      :attendance_bonus,
      :ot,
      :bonus,
      :position_allowance,
      :extra_etc,
      :absence,
      :late,
      :tax,
      :social_insurance,
      :fee_etc,
      :pvf,
      :advance_payment
    ])
    result.to_h.each { |k,v| result[k] = 0 if k != "id" && v.blank? }
    return result
  end

end
