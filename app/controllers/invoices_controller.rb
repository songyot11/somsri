class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :slip, :cancel]
  skip_before_action :verify_authenticity_token, :only => [:update, :create, :destroy, :cancel]
  load_and_authorize_resource

  # GET /invoices
  def index
    grade_select = (params[:grade_select] || 'All')
    start_date = DateTime.parse(params[:start_date]).beginning_of_day if isDate(params[:start_date])
    end_date = DateTime.parse(params[:end_date]).end_of_day if isDate(params[:end_date])

    invoice_status_id = nil
    if params[:is_active] == "1"
      invoice_status_id = InvoiceStatus.status_active_id
    end
    if params[:is_active] == "0"
      invoice_status_id = InvoiceStatus.status_canceled_id
    end

    @invoices = get_invoices(grade_select, params[:search_keyword], start_date, end_date, params[:page], params[:sort], params[:order], params[:export], invoice_status_id, params[:student_id])
    if params[:page] && @invoices.total_pages < @invoices.current_page
      @invoices = get_invoices(grade_select, params[:search_keyword], start_date, end_date, 1, params[:sort], params[:order], params[:export], invoice_status_id, params[:student_id])
    end

    @filter_grade = grade_select

    result = {}

    if params[:bootstrap_table].to_s == "1"
      # result = {
      #   rows: @invoices.as_json({ bootstrap_table: true })
      # }
      # if params[:page]
      #   result[:page] = @invoices.current_page
      #   result[:total] = @invoices.total_entries
      # end

      result = @invoices.as_json({ bootstrap_table: true })
    else
      result = {
        invoices: @invoices.as_json({ index: true })
      }
      if params[:page]
        result[:current_page] = @invoices.current_page
        result[:total_records] = @invoices.total_entries
      end
    end
    render json: result
  end

  # GET /invoices/:id
  def show
  end

  # GET /invoices/new
  def new
    last_invoice_id = Invoice.last ? Invoice.last.id : 0

    # get stduent info
    students = Student.all.to_a
    student_info = []
    student_code = []
    students.each do |student|

      student_number_display = student.invoice_screen_student_number_display

      full_name_display = student.invoice_screen_full_name_display

      student_info << {
        id: student.id,
        parent_id: student.parents[0] ? student.parents[0].id : '',
        full_name: student.full_name_with_title,
        nickname: student.nickname,
        student_number: student.student_number,
        student_number_display: student_number_display,
        full_name_display: full_name_display
      }
    end

    # get parent info
    parents = Parent.all.to_a
    parent_info = []
    parents.each do |parent|
      fullname_display = parent.invoice_screen_full_name_display
      parent_info << {
        id: parent.id,
        student_id: parent.students[0] ? parent.students[0].id : '',
        full_name: parent.full_name,
        mobile: parent.mobile,
        full_name_display: fullname_display
      }
    end

    #get line_item
    line_items = LineItem.pluck(:detail, :amount).uniq
    line_items_info = []
    line_items.each do |line_item|
      line_item_display = ""
      if(line_item[1])
        line_item_display = line_item[0] + '(' + line_item[1].to_s + ')'
      else
        line_item_display = line_item[0]
      end
      line_items_info << {
        detail: line_item[0],
        amount: line_item[1],
        line_item_display: line_item_display
      }
    end

    render json: {
      default_cash_payment_method: SiteConfig.get_cache.default_cash_payment_method,
      default_credit_card_payment_method: SiteConfig.get_cache.default_credit_card_payment_method,
      default_cheque_payment_method: SiteConfig.get_cache.default_cheque_payment_method,
      default_transfer_payment_method: SiteConfig.get_cache.default_transfer_payment_method,
      school_year: SchoolSetting.school_year,
      last_invoice_id: last_invoice_id,
      student_info: student_info,
      parent_info: parent_info,
      grades: Grade.names,
      line_items_info: line_items_info,
      current_semester: SchoolSetting.current_semester
    }, status: :ok
  end

  # POST /invoices
  def create
    grade = Grade.find_by_name(params["invoice"]["grade_name"]["value"])
    Invoice.transaction do
      parent = Parent.find_or_create_by(parent_params);
      student = nil
      qry_student = Student.all
      # Clean Up Student's name
      student_name = Student.clean_full_name(student_params[:full_name])

      # try to search by Student Number
      if student_params[:student_number].present? &&
        student_params[:student_number].size > 0 &&
        (student_params[:student_number].is_a? Integer) &&
        student_params[:student_number] > 0
        qry_student = qry_student.where(student_number: student_params[:student_number])
      end

      # try to search by Student name
      if student_name.present? && student_name.size > 0
        # student_arel_table = Student.arel_table
        # qry_student = qry_student.where(student_arel_table[:full_name].matches("%#{student_name}%"))
        qry_student = qry_student.where(full_name: student_name).or(
          Student.where(full_name_english: student_name))
      end

      student = qry_student.first

      # Stil not found create new Student
      if student.nil?
        # check name is thai or english
        if (student_name =~ /^[a-zA-Z]/) != nil
          student = Student.new(full_name_english: student_name,
            student_number: student_params[:student_number])
        else
          student = Student.new(full_name: student_name,
            student_number: student_params[:student_number])
        end

        # Detect Gender from prefix
        if ['ด.ช.','เด็กชาย','master'].any? { |word| student_params[:full_name].downcase.include?(word) }
          student.gender_id = Gender.male.id
        elsif ['ด.ญ.','เด็กหญิง','miss'].any? { |word| student_params[:full_name].downcase.include?(word) }
          student.gender_id = Gender.female.id
        end
      end

      # Save new data if enter by user
      if student && student.grade_id.nil?
        student.grade_id = grade.id
      end

      student.save

      if student.parents.size == 0 || student.parents.select{|p| p.full_name == parent.full_name}.size == 0
        StudentsParent.create(student_id: student.id, parent_id: parent.id, relationship_id: 2)
      end

      invoice_hash = invoice_params.to_h
      invoice_hash.delete(:items)
      invoice_hash.delete(:grade)
      invoice_hash.delete(:grade_name)

      if invoice_hash[:school_year].blank?
        invoice_hash[:school_year] = SchoolSetting.school_year
      else
        invoice_hash[:school_year]
      end

      invoice = Invoice.new(invoice_hash)
      invoice.parent_id = parent.id
      invoice.parent_name = parent.full_name
      invoice.student_id = student.id
      invoice.student_name = student.invoice_screen_full_name_display
      invoice.user_id = current_user.id
      invoice.user_name = current_user.name
      invoice.grade_name = grade.name
      invoice.classroom = student.classroom ? student.classroom.name : nil
      invoice.invoice_status_id = InvoiceStatus.find_by_name("Active").id

      line_item_params.to_h[:items].each do |item|
        invoice.line_items << LineItem.new(item)
      end

      pm = payment_method_params
      invoice.payment_methods << PaymentMethod.new({ payment_method: "เงินสด", amount: pm[:cash_amount] || 0}) if pm[:is_cash]
      invoice.payment_methods << PaymentMethod.new({ payment_method: "บัตรเครดิต", amount: pm[:credit_card_amount] || 0}) if pm[:is_credit_card]
      invoice.payment_methods << PaymentMethod.new({
          payment_method: "เงินโอน",
          amount: pm[:transfer_amount] || 0,
          transfer_bank_name: pm[:transfer_bank_name],
          transfer_date: pm[:transfer_date]
      }) if pm[:is_transfer]
      invoice.payment_methods << PaymentMethod.new({
          payment_method: "เช็คธนาคาร",
          amount: pm[:cheque_amount] || 0,
          invoice_id: invoice.id,
          cheque_bank_name: pm[:cheque_bank_name],
          cheque_date: pm[:cheque_date],
          cheque_number: pm[:cheque_number]
        }) if pm[:is_cheque]

      invoice.save
      render json: { id: invoice.id }, status: :ok
    end
  end

  # PATCH/PUT /invoices/:id
  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html { redirect_to @invoice, notice: 'Invoice was successfully updated.' }
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invoices/:id/cancel
  def cancel
    if @invoice.update(invoice_status_id: InvoiceStatus.find_by_name('Canceled').id)
      render json: ["SUCCESS"], status: :ok
    else
      render json: ["FAILED"], status: :ok
    end
  end

  # DELETE /invoices/:id
  def destroy
    @invoice.destroy
    respond_to do |format|
      format.html { redirect_to invoices_url, notice: 'Invoice was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /invoices/:id/slip
  def slip
    grade_name = @invoice.grade_name ? (@invoice.grade_name) : ""
    if @invoice.classroom
      grade_name << " (#{@invoice.classroom})"
    end

    school = School.first
    slip_info = {
      header: school.invoice_header_with_logo,
      footer: school.invoice_footer,
      logo: school.logo_url,
      slip_id: @invoice.id,
      thai_now_date: I18n.l(@invoice.created_at, format: "%d %B #{@invoice.created_at.year + 543}"),
      eng_now_date: @invoice.created_at.strftime("%d %B %Y"),
      semester: @invoice.semester,
      school_year: @invoice.school_year,
      school_year_en: (@invoice.school_year.to_i - 543).to_s,
      create_year: @invoice.created_at.year + 543, 
      payment_methods: [],
      remark: @invoice.remark,
      grade_name: grade_name,
      receiver_name: @invoice.user.name,
      parent: {
        display_name: @invoice.parent.full_name
      },
      student: {
        display_name: @invoice.student_name,
        student_number: @invoice.student.student_number
      },
      display_schools_year_with_invoice_id: SiteConfig.get_cache.display_schools_year_with_invoice_id
    }

    @invoice.payment_methods.to_a.each do |pm|
      if pm.payment_method == "เงินสด"
        slip_info[:is_cash] = true
        slip_info[:cash_amount] = pm.amount
      end

      if pm.payment_method == "บัตรเครดิต"
        slip_info[:is_credit_card] = true
        slip_info[:credit_card_amount] = pm.amount
      end

      if pm.payment_method == "เช็คธนาคาร"
        slip_info[:is_cheque] = true
        slip_info[:cheque_bank_name] = pm.cheque_bank_name
        slip_info[:cheque_number] = pm.cheque_number
        slip_info[:cheque_date] = pm.cheque_date
        slip_info[:cheque_amount] = pm.amount
      end

      if pm.payment_method == "เงินโอน"
        slip_info[:is_transfer] = true
        slip_info[:transfer_bank_name] = pm.transfer_bank_name
        slip_info[:transfer_date] = pm.transfer_date
        slip_info[:transfer_amount] = pm.amount
      end
    end

    line_items = []
    total = 0
    @invoice.line_items.each do |line_item|
      total += line_item.amount
      line_items << {
        detail: line_item.detail,
        amount: line_item.amount,
      }
    end

    slip_info["line_items"] = line_items if line_items.length > 0
    slip_info["total_amount"] = total

    respond_to do |format|
      format.html do
        render json: slip_info, status: :ok
      end
      format.pdf do
        @results = slip_info
        render pdf: "file_name",
                template: "pdf/invoice.html.erb",
                encoding: "UTF-8",
                layout: 'pdf.html',
                show_as_html: params[:show_as_html].present?
      end
    end
  end

  def invoice_years
    all_years = Invoice.pluck(:school_year).uniq
    render json: {
      all_years: all_years,
      current_year: SchoolSetting.school_year
    }
  end

  def invoice_semesters
    render json: {
      semesters: SchoolSetting.semesters,
      current_semester: SchoolSetting.current_semester
    }
  end

  def invoice_grouping
    display_payment_method = params[:display_payment_method].to_s == "true" ? true : false
    display_etc = params[:display_etc].to_s == "true" ? true : false
    grouping_keyword = GroupingReportOption.all.order(:id).to_a
    options = []
    if params[:options]
      # filter grouping_keyword
      options = JSON.parse(params[:options])
      selected_options = options.collect{|op| op["name"] if op["value"]}
      grouping_keyword.collect! do |gk|
        gk if selected_options.include? gk[:name]
      end
      grouping_keyword.compact!
    else
      options = grouping_keyword.collect{|gk| { name: gk[:name], value: true }}
    end

    start_date = isDate(params[:start_date]) ? DateTime.parse(params[:start_date]).beginning_of_day : nil
    end_date = isDate(params[:end_date]) ? DateTime.parse(params[:end_date]).end_of_day : nil

    summary_mode = select_summary_mode(start_date, end_date)
    summary_mode = params[:summary_mode] if params[:summary_mode] # force summary_mode
    invoices = query_invoice_by_date_range(start_date, end_date)

    if summary_mode == "per_student"
      invoices = invoices.order("student_id ASC").to_a
    elsif summary_mode == "per_day" || summary_mode == "per_invoice"
      invoices = invoices.order("created_at ASC").to_a
    end

    type = params[:type]
    header = []
    if display_payment_method
      header = [
        I18n.t('cash'),
        I18n.t('credit_card'),
        I18n.t('bank_check'),
        I18n.t('bank_transfer')
      ]
    end

    grouping_keyword.each do |gk|
      header << gk[:name]
    end

    if display_etc
      header << I18n.t('extra_etc')
    end
    header << I18n.t('sum')

    column_size =  6 + grouping_keyword.size
    column_size -= 4 if !display_payment_method
    column_size -= 1 if !display_etc

    header_row_name_tmp = ""
    header_row_date_tmp = ""
    header_row_invoice_id_tmp = ""
    header_row_classroom_tmp = ""
    student_id_tmp = "";
    datas_tmp = Array.new(column_size, 0.0)
    total_tmp = Array.new(column_size, 0.0)
    rows = []

    invoices.each do |invoice|
      if summary_mode == "per_student" && student_id_tmp != invoice.student_id
        # collect per student in one day
        if student_id_tmp != ""
          row = {
            header_row_name: header_row_name_tmp,
            header_row_invoice_id: header_row_invoice_id_tmp,
            header_row_classroom: header_row_classroom_tmp,
            datas: datas_tmp
          }
          row[:url] = edit_student_path(id: student_id_tmp) if Student.where(id: student_id_tmp).exists?
          rows << row
        end

        # reset tmp data
        student_id_tmp = invoice.student_id
        header_row_invoice_id_tmp = invoice.id
        header_row_classroom_tmp = invoice.student.grade_name_with_title_classroom
        header_row_name_tmp = invoice.student.invoice_screen_full_name_display
        datas_tmp = Array.new(column_size, 0.0)
      elsif summary_mode == "per_day" && header_row_date_tmp != invoice.created_at.strftime("%d/%m/%Y")
        # collect per day data
        if header_row_date_tmp != ""
          rows << {
            header_row_date: header_row_date_tmp,
            datas: datas_tmp
          }
        end

        # reset tmp data
        header_row_date_tmp = invoice.created_at.strftime("%d/%m/%Y")
        datas_tmp = Array.new(column_size, 0.0)
      elsif summary_mode == "per_invoice"
        row = {
          header_row_name: invoice.student.invoice_screen_full_name_display,
          header_row_invoice_id: invoice.id,
          header_row_classroom: invoice.student.grade_name_with_title_classroom,
          header_row_date: invoice.created_at.strftime("%d/%m/%Y"),
          datas: datas_tmp = Array.new(column_size, 0.0)
        }
        row[:url] = edit_student_path(id: student_id_tmp) if Student.where(id: student_id_tmp).exists?
        rows << row
      end
      if display_payment_method
        set_payment_method_datas(invoice, datas_tmp, total_tmp)
      end
      set_grouping_item(invoice, grouping_keyword, column_size, datas_tmp, total_tmp, display_etc, display_payment_method)
    end

    # add last date
    if summary_mode != "per_invoice"
      row = {
        header_row_name: header_row_name_tmp,
        header_row_date: header_row_date_tmp,
        header_row_invoice_id: header_row_invoice_id_tmp,
        header_row_classroom: header_row_classroom_tmp
      }
      row[:datas] = datas_tmp if invoices.size > 0
      row[:url] = edit_student_path(id: student_id_tmp) if Student.where(id: student_id_tmp).exists?
      rows << row
    end

    render json: {
      header: header,
      rows: rows,
      total: total_tmp,
      options: options
    }
  end

  private
    def set_grouping_item(invoice, grouping_keyword, column_size, datas_tmp, total_tmp, display_etc, display_payment_method)
      LineItem.where(invoice_id: invoice.id).to_a.each do |li|
        is_grouped = false
        keyword_index = 4
        keyword_index -= 4 if !display_payment_method
        grouping_keyword.each do |gk|
          if li.detail.downcase =~ Regexp.union(gk[:keyword].downcase.split('|').collect(&:strip))
            #sum by keyword
            datas_tmp[keyword_index] += li.amount
            total_tmp[keyword_index] += li.amount
            is_grouped = true
          end
          keyword_index += 1
          break if is_grouped
        end

        if !is_grouped && display_etc
          #sum by other
          datas_tmp[column_size - 2] += li.amount
          total_tmp[column_size - 2] += li.amount
          #sum all invoice
          datas_tmp[column_size - 1] += li.amount
          total_tmp[column_size - 1] += li.amount
        elsif is_grouped
          #sum all invoice
          datas_tmp[column_size - 1] += li.amount
          total_tmp[column_size - 1] += li.amount
        end

      end
    end

    def set_payment_method_datas(invoice, datas_tmp, total_tmp)
      invoice.payment_methods.each do |pm|
        # group by payment method
        if pm.payment_method == "เงินสด"
          datas_tmp[0] += pm.amount
          total_tmp[0] += pm.amount
        end
        if pm.payment_method == "บัตรเครดิต"
          datas_tmp[1] += pm.amount
          total_tmp[1] += pm.amount
        end
        if pm.payment_method == "เช็คธนาคาร"
          datas_tmp[2] += pm.amount
          total_tmp[2] += pm.amount
        end
        if pm.payment_method == "เงินโอน"
          datas_tmp[3] += pm.amount
          total_tmp[3] += pm.amount
        end
      end
    end

    def select_summary_mode(start_date, end_date)
      summary_mode = "per_day"
      if start_date && end_date && start_date.to_date == end_date.to_date
        summary_mode = "per_student"
      end
      return summary_mode
    end

    def query_invoice_by_date_range(start_date, end_date)
      qry_invoices = Invoice.where(invoice_status_id: InvoiceStatus.find_by_name('Active').id)
      data_field = Invoice.arel_table[:created_at]
      qry_invoices = qry_date_range(qry_invoices, data_field, start_date, end_date)
      return qry_invoices
    end

    def get_invoices(grade_select, search_keyword, start_date, end_date, page, sort, order, export, invoice_status_id, student_id)
      qry_invoices = Invoice.includes(:payment_methods, :parent, :student, :user, :line_items, :invoice_status)
                            .search(search_keyword)

      qry_invoices = qry_invoices.where(invoice_status_id: invoice_status_id) if invoice_status_id
      qry_invoices = qry_invoices.where(student_id: student_id) if student_id

      if grade_select.downcase != 'all'
        grade = Grade.where(name: grade_select).first
        qry_invoices = qry_invoices.where(grade_name: grade.name) if grade
      end

      data_field = Invoice.arel_table[:created_at]
      qry_invoices = qry_date_range(qry_invoices, data_field, start_date, end_date)

      qry_invoices = qry_invoices.order("#{sort} #{order}")

      if export == 'export'
        qry_invoices = qry_invoices.paginate(page: page, per_page: Invoice.count)
      elsif page
        qry_invoices = qry_invoices.paginate(page: page, per_page: 10)
      end

      return qry_invoices.to_a
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invoice_params
      params.require(:invoice).permit(:student_id, :parent_id, :user_id, :remark, :cheque_bank_name, :cheque_number, :cheque_date, :transfer_bank_name, :transfer_date, :invoice_status_id, :school_year, :semester, grade_name: [:value, :text])
    end

    def parent_params
      params.require(:parent).permit(:full_name, :full_name_english, :nickname, :nickname_english, :mobile, :email, :line_id)
    end

    def student_params
      params.require(:student).permit(:full_name, :full_name_english, :nickname, :nickname_english, :gender_id, :birthdate, :grade_id, :classroom, :classroom_number, :student_number, :national_id, :remark)
    end

    def line_item_params
      params.require(:invoice).permit(items: [[:detail, :amount]])
    end

    def payment_method_params
      params.require(:payment_method).permit(:is_cash, :is_credit_card, :is_cheque, :cheque_bank_name, :cheque_number, :cheque_date, :is_transfer, :transfer_date, :transfer_bank_name, :cash_amount, :credit_card_amount, :credit_card_amount, :cheque_amount, :transfer_amount)
    end
end
