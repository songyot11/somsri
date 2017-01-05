class ReportsController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:update]

  # GET /reports
  def index
    render json: getMonths(params[:employee_id]), status: :ok
  end

  # GET /reports/:year/:month
  def payroll
    year = params[:year].to_i
    month = params[:month].to_i
    start_month = Date.new(year, month, 1)
    end_month = start_month.end_of_month
    employees = Employee.active.where(school_id: current_user.school.id)
    payrolls = Payroll.joins(:employee)
                      .where(employee_id: employees, created_at: start_month.beginning_of_day..end_month.end_of_day)
                      .order('employees.start_date ASC, employees.created_at ASC')
                      .as_json("report")

    render json: payrolls, status: :ok
  end

  # PATCH /reports/:id
  def update
    payroll = Payroll.find(params[:id])
    if payroll.update(params_payroll)
      render json: payroll, status: :ok
    else
      render json: {error: payroll.errors.full_message}, status: :bad_request
    end
  end

  private
    def getMonths(employee_ids)
      employee_ids = Employee.active.where(school_id: current_user.school.id) if !employee_ids
      months = Payroll.where(employee_id: employee_ids).order("created_at DESC").map { |d| I18n.l(d.created_at, format: "%m %B %Y").split(" ") }.uniq

      months = months.collect { |x|
        {
          month: x[0].to_i,
          name: x[1],
          year: x[2],
        }
      }
    end

    def params_payroll
      params.require(:payroll).permit(:salary, :allowance, :attendance_bonus, :ot, :bonus, :position_allowance,
                                      :extra_etc, :absence, :late, :tax, :social_insurance, :fee_etc, :pvf,
                                      :advance_payment)
    end
end
