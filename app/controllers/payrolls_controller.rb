class PayrollsController < ApplicationController
  include PdfUtils
  skip_before_action :verify_authenticity_token, :only => [:update]

  # GET /payrolls
  def index
    if params[:employee_id]
      render json: get_months_by_employee_ids(params[:employee_id]), status: :ok
    else
      render json: get_months(params[:employee_id]), status: :ok
    end
  end

  # GET /payrolls/:year/:month
  def payroll
    year = params[:year].to_i
    month = params[:month].to_i
    start_month = Date.new(year, month, 1)
    end_month = start_month.end_of_month
    employees = Employee.active.where(school_id: current_user.school.id)
    payrolls = Payroll.joins(:employee)
                      .where(employee_id: employees, effective_date: start_month.beginning_of_day..end_month.end_of_day)
                      .order('employees.start_date ASC, employees.created_at ASC')
                      .as_json("report")

    render json: payrolls, status: :ok
  end

  # PATCH /payrolls/:id
  def update
    payroll = Payroll.find(params[:id])
    if payroll.update(params_payroll)
      render json: payroll, status: :ok
    else
      render json: {error: payroll.errors.full_message}, status: :bad_request
    end
  end

  # GET /payrolls/social_insurance_pdf
  def social_insurance_pdf
    year = params[:year].to_i
    month = params[:month].to_i
    start_month = Date.new(year, month, 1)
    end_month = start_month.end_of_month
    employees = Employee.where(school_id: current_user.school.id).order(:id).to_a
    payrolls = Payroll.joins(:employee)
                      .where(employee_id: employees, effective_date: start_month.beginning_of_day..end_month.end_of_day)
                      .where("social_insurance > ?", 0)
                      .order('employee_id').to_a
    render text: "ไม่มีพนักงานที่ต้องเสียค่าประกันสังคม", status: :ok and return if payrolls.size == 0 || payrolls.blank?
    employee_count = payrolls.size
    sum_salary = 0
    sum_insurance = 0
    fill_form_data = {}
    i = 1
    payrolls.each do |payroll|
      salary = salary_by_law(payroll.salary)
      sum_salary += salary
      sum_insurance += payroll.social_insurance
      i += 1
    end

    template_header = 'public/sps1-1.pdf'
    template_detail = 'public/sps1-2.pdf'
    tmp_dir = "tmp/#{random_string}"
    output_file = generate_pdf_file_name('tmp/sps1')
    FileUtils.mkdir_p "tmp/sps1" unless File.directory?("tmp/sps1")

    page_amount = (payrolls.count / 10.0).ceil.to_i
    school = current_user.school
    thai_date = to_thai_date(payrolls[0].effective_date)

    # generate header page pdf
    header_data = [
      [
        { text: school.name, location: [100, 480] },
        # { text: "ชื่อสาขา", location: [70, 458] },
        { text: school.address, location: [10, 413] },
        { text: school.zip_code, location: [68, 390] },
        { text: school.phone, location: [150, 390] },
        { text: school.fax, location: [270, 390] },
        { text: thai_date[1], location: [150, 368] },
        { text: thai_date[2], location: [265, 368] },
        { text: sum_salary.to_i, location: [207, 305] },
        { text: satang(sum_salary), location: [297, 305] },
        { text: sum_insurance.to_i, location: [207, 284] },
        { text: "00", location: [297, 284] },
        { text: sum_insurance.to_i, location: [207, 265] },
        { text: "00", location: [297, 265] },
        { text: (sum_insurance * 2).to_i, location: [207, 245] },
        { text: "00", location: [297, 245] },
        # { text: "เงินบาทในภาษาไทย", location: [20, 226] },
        { text: employee_count, location: [207, 206] },
        { text: "/", location: [3, 138] },
        { text: page_amount, location: [180, 138] }
      ]
    ]
    header_pdfs = generate_pdf(template_header, header_data, tmp_dir) do |file, data|
      Prawn::Document.generate(file, :page_layout => :landscape) do
        data.each do |d|
          font("public/fonts/THSarabunNew.ttf") do
            text_box d[:text].to_s, at: d[:location], size: 16
          end
        end
      end
    end

    # generate detail page pdf
    detail_datas = []
    page_number = 1
    order = 1
    payrolls.each_slice(10) do |p10|
      data = [
        { text: thai_date[1], location: [90, 540] },
        { text: thai_date[2], location: [215, 540] },
        { text: page_number, location: [565, 540] },
        { text: page_amount, location: [655, 540] },
        { text: school.name, location: [165, 495] }
      ]

      if page_amount == page_number
        data.push([
          { text: sum_salary.to_i, location: [520, 150] },
          { text: satang(sum_salary), location: [603, 150] },
          { text: sum_insurance.to_i, location: [625, 150] }
        ]).flatten!
      end

      order_per_page = 0
      new_line_margin = 30
      p10.each do |p|
        e = p.employee
        personal_digits = e.personal_id.gsub('-', '').split('')
        new_line_margin = 22 * order_per_page
        employee_data = [
          { text: order, location: [15, (380 - new_line_margin)] },
          { text: personal_digits[0], location: [55, (383 - new_line_margin)], rect: [[50, (380 - new_line_margin)], 15, 15] },
          { text: "-", location: [68, (383 - new_line_margin)]},
          { text: personal_digits[1], location: [77, (383 - new_line_margin)], rect: [[72, (380 - new_line_margin)], 15, 15] },
          { text: personal_digits[2], location: [92, (383 - new_line_margin)], rect: [[87, (380 - new_line_margin)], 15, 15] },
          { text: personal_digits[3], location: [107, (383 - new_line_margin)], rect: [[102, (380 - new_line_margin)], 15, 15] },
          { text: personal_digits[4], location: [122, (383 - new_line_margin)], rect: [[117, (380 - new_line_margin)], 15, 15] },
          { text: "-", location: [133, (383 - new_line_margin)]},
          { text: personal_digits[5], location: [144, (383 - new_line_margin)], rect: [[139, (380 - new_line_margin)], 15, 15] },
          { text: personal_digits[6], location: [159, (383 - new_line_margin)], rect: [[154, (380 - new_line_margin)], 15, 15] },
          { text: personal_digits[7], location: [174, (383 - new_line_margin)], rect: [[169, (380 - new_line_margin)], 15, 15] },
          { text: personal_digits[8], location: [189, (383 - new_line_margin)], rect: [[184, (380 - new_line_margin)], 15, 15] },
          { text: personal_digits[9], location: [204, (383 - new_line_margin)], rect: [[199, (380 - new_line_margin)], 15, 15] },
          { text: "-", location: [215, (383 - new_line_margin)]},
          { text: personal_digits[10], location: [226, (383 - new_line_margin)], rect: [[221, (380 - new_line_margin)], 15, 15] },
          { text: personal_digits[11], location: [241, (383 - new_line_margin)], rect: [[236, (380 - new_line_margin)], 15, 15] },
          { text: "-", location: [252, (383 - new_line_margin)]},
          { text: personal_digits[12], location: [263, (383 - new_line_margin)], rect: [[258, (380 - new_line_margin)], 15, 15] },
          { text: p.employee.full_name, location: [290, (380 - new_line_margin)] },
          { text: salary_by_law(p.salary).to_i, location: [520, (380 - new_line_margin)] },
          { text: satang(salary_by_law(p.salary)), location: [603, (380 - new_line_margin)] },
          { text: p.social_insurance.to_i, location: [625, (380 - new_line_margin)] }
        ]

        data.push(employee_data).flatten!
        order_per_page += 1
        order += 1
      end

      detail_datas.push(data)
      page_number += 1
    end

    data_pdfs = generate_pdf(template_detail, detail_datas, tmp_dir) do |file, data|
      Prawn::Document.generate(file, :page_layout => :landscape) do
        data.each do |d|
          font("public/fonts/THSarabunNew.ttf") do
            text_box d[:text].to_s, at: d[:location], size: 16
          end
          stroke do
            rectangle d[:rect][0], d[:rect][1], d[:rect][2] if d[:rect]
          end
        end
      end
    end

    # merge haeder and data
    PDF::Toolkit.pdftk(header_pdfs, data_pdfs, "cat", "output", output_file)

    FileUtils.rm_rf tmp_dir # remove all tmp
    send_file(output_file, :filename => 'social_insurance_pdf.pdf', :disposition => 'inline', :type => 'application/pdf')
  end

  private
    def get_months(employee_ids)
      employee_ids = Employee.active.where(school_id: current_user.school.id)
      payroll_dates = Payroll.where(employee_id: employee_ids)
                             .order("effective_date DESC")
                             .distinct.pluck(:effective_date).uniq
      months = []
      payroll_dates.to_a.each do |payroll_date|
        d = I18n.l(payroll_date, format: "%dd %m %B %Y").split(" ")
        months.push({
          date: d[0].to_i,
          month: d[1].to_i,
          name: d[2],
          year: d[3]
        })
      end
      return months
    end

    def to_thai_date(date_time)
      d = I18n.l(date_time, format: "%d %B %Y").split(" ")
      return [ d[0].to_i, d[1], d[2].to_i + 543 ]
    end

    def salary_by_law(salary)
      salary < 15000 ? 15000 : salary
    end

    def get_months_by_employee_ids(employee_ids)
      payrolls = Payroll.where(employee_id: employee_ids)
                             .order("effective_date DESC")
      months = []
      payrolls.to_a.each do |payroll|
        d = I18n.l(payroll.effective_date, format: "%dd %m %B %Y").split(" ")
        months.push({
          date: d[0].to_i,
          month: d[1].to_i,
          name: d[2],
          year: d[3],
          payroll_id: payroll.id
        })
      end
      return months
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
