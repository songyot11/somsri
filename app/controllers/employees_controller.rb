class EmployeesController < ApplicationController
  load_and_authorize_resource
  skip_before_action :verify_authenticity_token, :only => [:update, :create, :destroy]

  # GET /employees
  def index
    employee = Employee.active.order('employees.start_date ASC, employees.created_at ASC')
                              .as_json(employee_list: true)
    render json: employee, status: :ok
  end

  # GET /employees/:id/slip
  def slip
    employee = Employee.active.find(params[:id]).as_json({ slip: true, payroll_id: params[:payroll_id] })
    employee[:payroll][:fee_orders] = employee[:payroll][:fee_orders]
                                                      .select { |key, value| value[:value] > 0}
    employee[:payroll][:pay_orders] = employee[:payroll][:pay_orders]
                                                      .select { |key, value| value[:value] > 0}
    render json: employee, status: :ok
  end

  # GET /employees/:id/payrolls
  def payrolls
    payrolls = Employee.active.find(params[:id]).payrolls
                       .order("created_at desc")
                       .as_json("history")
    render json: payrolls, status: :ok
  end

  # GET /employees/:id
  def show
    @employee = Employee.active.find(params[:id])
    payroll = @employee.lastest_payroll
    tax_reduction = @employee.tax_reduction
    if params[:payroll_id]
      payroll = @employee.payroll(params[:payroll_id])
    end
    render json: {
      employee: @employee,
      payroll: payroll,
      tax_reduction: tax_reduction
    }
  end

  def create
    school = current_user.school
    render json: employee.errors, status: 500 and return if !school

    employee = school.employees.new(employee_params)
    if employee.save
        render json: {
          employee: employee
        }, status: :ok
    else
      render json: employee.errors, status: 500
    end
  end

  # GET /employees/calculate_outcome/:id
  def calculate_outcome
    p = eval(params.require(:payroll))
    e = eval(params.require(:employee).gsub! 'null', 'nil')
    t = eval(params.require(:tax_reduction))
    render json: {tax: Payroll.generate_tax(p, e, t), social_insurance: Payroll.generate_social_insurance(p, e), pvf: Payroll.generate_pvf(p, e)}
  end

  # PATCH /employees/:id
  def update
    employee_datas = employee_params
    employee_datas.delete(:id)
    employee = Employee.update(params[:id] , employee_datas)

    if params[:payroll]
      payroll_datas = payroll_params
      payroll_id = payroll_datas[:id]
      payroll_datas[:salary] = employee_datas[:salary]
      payroll_datas.delete(:id)
      payroll = Payroll.update(payroll_id, payroll_datas)
    end

    if params[:tax_reduction]
      tax_reduction_datas = tax_reduction_params
      tax_reduction_id = tax_reduction_datas[:id]
      tax_reduction = TaxReduction.update(tax_reduction_id, tax_reduction_datas)
    end

    render json: {
      employee: employee,
      payroll: employee.lastest_payroll,
      tax_reduction: employee.tax_reduction
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
      :birthdate,
      :img_url,
      :employee_type,
      :address,
      :tel,
      :email,
      :status,
      :pay_pvf,
      :pay_social_insurance
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

  def tax_reduction_params
    result = params.require(:tax_reduction).permit([
      :id,
      :employee_id,
      :pension_insurance,
      :pension_fund,
      :government_pension_fund,
      :private_teacher_aid_fund,
      :retirement_mutual_fund,
      :national_savings_fund,
      :expenses,
      :no_income_spouse,
      :child,
      :father_alimony,
      :spouse_father_alimony,
      :cripple_alimony,
      :father_insurance,
      :insurance,
      :spouse_insurance,
      :long_term_equity_fund,
      :social_insurance,
      :double_donation,
      :donation,
      :other,
      :mother_alimony,
      :spouse_mother_alimony,
      :mother_insurance,
      :spouse_father_insurance,
      :spouse_mother_insurance,
      :house_loan_interest
    ])
    result.to_h.each { |k,v| result[k] = 0 if k != "id" && v.blank? }
    return result
  end
end
