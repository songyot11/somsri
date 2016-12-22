class ReportsController < ApplicationController
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
    payrolls = Payroll.where(created_at: start_month.beginning_of_day..end_month.end_of_day)
                      .order("id ASC")
                      .as_json('report')

    render json: payrolls, status: :ok
  end

  private
    def getMonths
      months = Payroll.order("created_at DESC").map { |d| I18n.l(d.created_at, format: "%m %B %Y").split(" ") }.uniq

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
