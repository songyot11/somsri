class ReportsController < ApplicationController
  authorize_resource :class => :report
  # GET /reports
  def index
    getMonths()
  end

  # GET /reports/:year/:month
  def payroll
    year = params[:year].to_i
    month = params[:month].to_i
    start_month = Date.new(year, month, 1)
    end_month = start_month.end_of_month
    employees = Employee.where(school_id: current_user.school.id)
    payrolls = Payroll.joins(:employee).where(employee_id: employees, created_at: start_month.beginning_of_day..end_month.end_of_day)
                      .as_json("report")
                      .sort{ |x, y| x["start_date"]<=>y["start_date"]}
    puts payrolls
    render json: payrolls, status: :ok
  end

  private
    def getMonths
      employee_ids = Employee.where(school_id: current_user.school.id)
      months = Payroll.where(employee_id: employee_ids).order("created_at DESC").map { |d| I18n.l(d.created_at, format: "%m %B %Y").split(" ") }.uniq

      months = months.collect { |x|
        {
          month: x[0].to_i,
          name: x[1],
          year: x[2],
        }
      }

      render json: months, status: :ok
    end
end
