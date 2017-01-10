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

  # GET /reports/social_insurance_pdf
  def social_insurance_pdf

    year = params[:year].to_i
    month = params[:month].to_i

    # year = 2017
    # month = 1

    start_month = Date.new(year, month, 1)
    end_month = start_month.end_of_month
    employees = Employee.where(school_id: current_user.school.id).order(:id).limit(35).to_a
    payrolls = Payroll.joins(:employee)
                      .where(employee_id: employees, created_at: start_month.beginning_of_day..end_month.end_of_day)
                      .order('employee_id').to_a
    employee_count = employees.size
    sum_salary = 0
    sum_insurance = 0
    fill_form_data = {}
    i = 1
    payrolls.each do |payroll|
      salary = payroll.salary < 15000 ? 15000 : payroll.salary
      sum_salary += salary
      sum_insurance += payroll.social_insurance

      fill_form_data["Pay_R#{i}".to_sym] = salary.to_i
      fill_form_data["Pay_L#{i}".to_sym] = satang(salary)
      fill_form_data["Among#{i}".to_sym] = payroll.social_insurance ? payroll.social_insurance.to_i : 0
      i += 1
    end

    # เงินเดือนทั้งสิ้น
    fill_form_data[:Pay_Date01] = sum_salary.to_i
    fill_form_data[:Payment2] = satang(sum_salary)
    # เงินสมทบผู้ประกันตน
    fill_form_data[:Pay_Date1] = sum_insurance.to_i
    fill_form_data[:SSO_Fund1] = "00"
    # เงินสมทบนายจ้าง
    fill_form_data[:SSO_Fund3] = sum_insurance.to_i
    fill_form_data[:SSO_Fund4] = "00"
    # เงินสมบทนำส่งทั้งสิ้น
    fill_form_data[:SSO_Fund5] = (sum_insurance * 2).to_i
    fill_form_data[:SSO_Fund6] = "00"

    # จำนวนผู้ประกันตน
    fill_form_data[:SSO_Fund8] = employee_count

    # เงินรวมของตาราง
    fill_form_data[:Among_All] = sum_insurance.to_i
    fill_form_data[:Pay_R_All] = sum_salary.to_i
    fill_form_data[:Pay_L_All] = satang(sum_salary)

    pdf_path = 'public/sps1.pdf'
    pdf_out_path = 'public/sps1_out.pdf'
    pdftk = PdfForms.new('/usr/local/bin/pdftk', data_format: 'XFdf', utf8_fields: true)
    name = pdftk.get_field_names pdf_path
    pdftk.fill_form pdf_path, pdf_out_path, fill_form_data
    send_file(pdf_out_path, :filename => 'social_insurance_pdf.pdf', :disposition => 'inline', :type => 'application/pdf')
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

    def satang(money)
      ((money - money.to_i) * 100).to_i.to_s.rjust(2, "0")
    end
end
