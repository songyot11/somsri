class PayrollsController < ApplicationController
  include PdfUtils
  include ActionView::Helpers::NumberHelper
  skip_before_action :verify_authenticity_token, :only => [:update, :create]
  load_and_authorize_resource

  # GET /payrolls
  def index
   
    effective_date = nil
    if params[:effective_date] != "lasted"
      effective_date = DateTime.parse(params[:effective_date])
      employee_ids = Payroll.where(effective_date: effective_date.beginning_of_day..effective_date.end_of_day).pluck(:employee_id)
      employees = Employee.with_deleted.where(id: employee_ids)
    else
      employees = Employee.all
    end

    payroll_report = params[:payroll_report]
    normal = params[:normal]
    temporary = params[:temporary]
    probationary = params[:probationary]
    daily = params[:daily]

    type = []
    if payroll_report
      type.push("ลูกจ้างประจำ") if normal == 'true'
      type.push("ลูกจ้างชั่วคราว") if temporary == 'true'
      type.push("ลูกจ้างทดลองงาน") if probationary == 'true'
      type.push("ลูกจ้างรายวัน") if daily == 'true'
      employees = employees.where(employee_type: type)
    end

    qry_payrolls = Payroll.with_deleted.where(employee_id: employees.ids)

    effective_date = nil 
    if params[:effective_date] != "lasted"
      effective_date = DateTime.parse(params[:effective_date])
      qry_payrolls = qry_payrolls.where(effective_date: effective_date.beginning_of_day..effective_date.end_of_day)
    else
      qry_payrolls = qry_payrolls.where(effective_date: nil)
    end
    payrolls = qry_payrolls.order('employee_id').to_a

    if params[:ktb_salary_xls] && effective_date
      # generate KTB salary excel
      (tmp_path, filename) = generate_ktb_salary_xls(effective_date, payrolls)
      send_file(tmp_path + filename, filename: filename, :disposition => 'inline', :type => 'application/xls')
    elsif params[:kbank_salary_txt] && effective_date
      # generate K-Biz salary txt
      (tmp_path, filename) = generate_kbiz_salary_txt(effective_date, payrolls)
      send_file(tmp_path + filename, filename: filename, :disposition => 'inline', :type => 'application/text')
    else
      respond_to do |format|
        format.html do
          render json: {
            payrolls: payrolls.as_json("report"),
            export_ktb_payroll: SiteConfig.get_cache.export_ktb_payroll,
            export_kbank_payroll: SiteConfig.get_cache.export_kbank_payroll
          }, status: :ok
        end
        format.pdf do
          @results = payrolls.as_json("report")
          @total = {
            salary: 0,
            ot: 0,
            position_allowance: 0,
            allowance: 0,
            attendance_bonus: 0,
            bonus: 0,
            extra_etc: 0,
            absence: 0,
            late: 0,
            tax: 0,
            social_insurance: 0,
            pvf: 0,
            advance_payment: 0,
            fee_etc: 0,
            net_salary: 0
          }
          @results.each do |result|
            @total[:salary] += result[:salary]
            @total[:ot] += result[:ot]
            @total[:position_allowance] += result[:position_allowance]
            @total[:allowance] += result[:allowance]
            @total[:attendance_bonus] += result[:attendance_bonus]
            @total[:bonus] += result[:bonus]
            @total[:extra_etc] += result[:extra_etc]
            @total[:absence] += result[:absence]
            @total[:late] += result[:late]
            @total[:tax] += result[:tax]
            @total[:social_insurance] += result[:social_insurance]
            @total[:pvf] += result[:pvf]
            @total[:advance_payment] += result[:advance_payment]
            @total[:fee_etc] += result[:fee_etc]
            @total[:net_salary] += result[:net_salary]
          end

          if params[:payroll_report]
            template = "pdf/payroll_report.html.erb"
            orientation = "Portrait"
            if effective_date
              filename = "ใบสรุปรายการ-#{effective_date.strftime("%d-%m-%Y")}"
            else
              filename = "ใบสรุปรายการ-เดือนปัจจุบัน"
            end
          else
            template = "pdf/payroll.html.erb"
            orientation = "Landscape"
            if effective_date
              filename = "เงินเดือน-#{effective_date.strftime("%d-%m-%Y")}"
              @effective_date_str = to_thai_date(effective_date).join(" ")
            else
              filename = "เงินเดือน-เดือนปัจจุบัน"
              @effective_date_str = t('this_month')
            end
          end
          render pdf: filename,
                  template: template,
                  orientation: orientation,
                  encoding: "UTF-8",
                  layout: 'pdf.html',
                  show_as_html: params[:show_as_html].present?
        end
      end
    end
  end

  # GET /payrolls/effective_dates
  def effective_dates
    if params[:employee_id]
      render json: get_months_by_employee_ids(params[:employee_id], params[:time_zone]), status: :ok
    else
      render json: get_months(params[:closed], params[:time_zone]), status: :ok
    end
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
    effective_date = DateTime.parse(params[:effective_date])
    employees = Employee.with_deleted.all.order(:id).to_a
    payrolls = Payroll.where(employee_id: employees, effective_date: effective_date.beginning_of_day..effective_date.end_of_day)
                      .where("social_insurance > ?", 0)
                      .order('employee_id').to_a
    render plain: I18n.t('social_insurance_pdf'), status: :ok and return if payrolls.size == 0 || payrolls.blank?
    employee_count = payrolls.size
    sum_salary = 0
    sum_insurance = 0
    fill_form_data = {}
    i = 1
    payrolls.each do |payroll|
      salary = payroll.salary
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
    school = School.first
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
          font(Rails.root.join('app', 'assets', 'fonts', 'THSarabunNew.ttf').to_s) do
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
          { text: p.salary.to_i, location: [520, (380 - new_line_margin)] },
          { text: satang(p.salary), location: [603, (380 - new_line_margin)] },
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
          font(Rails.root.join('app', 'assets', 'fonts', 'THSarabunNew.ttf').to_s) do
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

  # POST /payrolls/
  def create
    effective_date = DateTime.parse(create_params[:effective_date])
    if effective_date
      render json: [] and return if Payroll.where(effective_date: effective_date).count > 0
      Payroll.where(closed: [nil, false]).update_all(closed: true, effective_date: DateTime.parse(create_params[:effective_date]))
      Employee.all.without_deleted.to_a.each do |employee|
        if employee.lastest_payroll.nil?
          payroll = Payroll.new({
            employee_id: employee.id
          })
        else
          payroll = Payroll.new({
            employee_id: employee.id,
            salary: employee.lastest_payroll.salary,
            position_allowance: employee.lastest_payroll.position_allowance,
            allowance: employee.lastest_payroll.allowance
          })
        end
        payroll.save
      end
      render json: ["PAYROLLS_CREATED"], status: :ok
    end
  end

  private
    def get_months(isClosed, time_zone)
      employee_ids = Employee.with_deleted.all
      payroll_dates = Payroll.where(employee_id: employee_ids)
      if isClosed
        payroll_dates = payroll_dates.where(closed: true)
      end
      payroll_dates = payroll_dates.distinct
                                  .order("effective_date DESC")
                                  .pluck(:effective_date)
                                  .uniq

      effective_dates = []
      payroll_dates.to_a.each do |payroll_date|
        effective_dates.push({
          date_time: payroll_date ? payroll_date.in_time_zone(time_zone) : "lasted",
          date_string: payroll_date ? to_thai_date(payroll_date.in_time_zone(time_zone)).join(" ") : t('current_month'),
        })
      end
      return effective_dates
    end

    def to_thai_date(date_time)
      d = I18n.l(date_time, format: "%d %B %Y").split(" ")
      return [ d[0].to_i, d[1], d[2].to_i + 543 ]
    end

    def get_months_by_employee_ids(employee_ids, time_zone)
      payrolls = Payroll.where(employee_id: employee_ids)
                             .order("effective_date DESC")
      effective_dates = []
      payrolls.to_a.each do |payroll|
        effective_dates.push({
          date_string: payroll.effective_date ? to_thai_date(payroll.effective_date.in_time_zone(time_zone)).join(" ") : t('current_month'),
          payroll_id: payroll.id
        })
      end
      return effective_dates
    end

    def params_payroll
      params.require(:payroll).permit(:salary, :allowance, :attendance_bonus, :ot, :bonus, :position_allowance,
                                      :extra_etc, :absence, :late, :tax, :social_insurance, :fee_etc, :pvf,
                                      :advance_payment, :effective_date)
    end

    def create_params
      params.require(:create).permit(:effective_date)
    end

    def option_params
      params.require(:option).permit(:force_create)
    end

    def satang(money)
      ((money - money.to_i) * 100).to_i.to_s.rjust(2, "0")
    end

    def generate_ktb_salary_xls(effective_date, payrolls)
      book = Spreadsheet.open 'public/ktb_salary_template.xls'
      sheet1 = book.worksheet 0

      filename = "ktb_salary_#{effective_date.strftime("%F")}.xls"
      tmp_path = 'tmp/ktb_salary/'

      #header
      sheet1.row(2)[1] = School.first.name
      sheet1.row(1)[3] = filename
      sheet1.row(1)[1] = nil
      sheet1.row(0)[4] = nil
      sheet1.row(3)[1] = nil

      bank_code = "006"
      sum_salary = 0.0
      i = 0
      payrolls.each do |payroll|
        if payroll.net_salary > 0
          sum_salary += payroll.net_salary
          account_number = payroll.employee.account_number
          account_number.gsub!("-", "") if account_number
          sheet1.insert_row (i + 5), [
            i + 1,
            bank_code,
            account_number,
            number_with_precision(payroll.net_salary, precision: 2, delimiter: ','),
            nil,
            payroll.employee.full_name.strip
          ]
          i += 1
        end
      end
      sheet1.row(i + 5)[0] = "Total"
      sheet1.row(i + 5)[3] = number_with_precision(sum_salary, precision: 2, delimiter: ',')

      FileUtils.mkdir_p tmp_path unless File.directory?(tmp_path)
      book.write(tmp_path + filename)

      return [tmp_path, filename]
    end

    def generate_kbiz_salary_txt(effective_date, payrolls)
      filename = "kbiz_salary_#{effective_date.strftime("%F")}.txt"
      tmp_path = 'tmp/kbiz_salary/'

      FileUtils.mkdir_p tmp_path unless File.directory?(tmp_path)

      bank_code = SiteConfig.get_cache.bank_account
      sum_salary = 0.0
      i = 0
      employee_salary = []

      payrolls.each do |payroll|
        if payroll.net_salary > 0
          sum_salary += payroll.net_salary
          account_number = payroll.employee.account_number
          account_number.gsub!("-", "") if account_number

          net_salary = sprintf("%.2f", payroll.net_salary)
          total = net_salary.split('.')[0]
          decimal = net_salary.split('.')[1]
          length_name = payroll.employee.full_name_or_id.mb_chars.length

          employee_salary << [
            "D#{sprintf('%06d', (i + 1))}" + add_space(14),
            "#{account_number} ",
            "#{sprintf('%013d', total) + decimal} ",
            "#{Date.today.strftime("%y%m%d")}" + add_space(25),
            "#{payroll.employee.full_name_or_id}" + add_space(50 - length_name),
            "#{effective_date.strftime("%y%m%d")}000000",
            add_space(164) + "0000000000.000000000000.000000000000.00" + add_space(143)
          ]
          i += 1
        end
      end

      number_total = sprintf("%.2f", sum_salary)
      total = number_total.split('.')[0]
      decimal = number_total.split('.')[1]
      length_school = School.first.name.mb_chars.length

      content = "HPCT" + add_space(3)
      content += "import_" + effective_date.strftime("%d%m%y") + "000000" + add_space(14)
      content += "#{bank_code} "
      content += "#{sprintf('%013d', total) + decimal} "
      content += "#{Date.today.strftime("%y%m%d")}" + add_space(25)
      content += "#{School.first.name}" + add_space(50 - length_school)
      content += "#{effective_date.strftime("%y%m%d")}000000#{sprintf('%012d', i)}N" + add_space(5)
      content += "\r\n"

      employee_salary.each do |payroll|
        content += payroll.join("")
        content += "\r\n"
      end

      File.open(tmp_path + filename, "w+") do |f|
        f.write(content)
      end

      return [tmp_path, filename]
    end

    def add_space(num)
      str = ""
      (1..num).each {|i| str += " "}
      return str
    end
end
