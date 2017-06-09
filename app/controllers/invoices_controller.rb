class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :slip, :cancel]
  skip_before_action :verify_authenticity_token, :only => [:update, :create, :destroy, :cancel]
  load_and_authorize_resource

  # GET /invoices
  def index
    grade_select = (params[:grade_select] || 'All')
    @invoices = get_invoices(grade_select, params[:search_keyword], params[:page])
    if @invoices.total_pages < @invoices.current_page
      @invoices = get_invoices(grade_select, params[:search_keyword], 1)
    end
    @filter_grade = grade_select
    render json: {
      current_page: @invoices.current_page,
      total_records: @invoices.total_entries,
      invoices: @invoices.as_json({ index: true })
    }
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
      # Clean Up Student's name
      student_name = student_params[:full_name].gsub('ด.ช.', '').gsub('ด.ญ.', '').gsub('เด็กหญิง', '').gsub('เด็กชาย', '').strip.gsub(/\s+/,' ')

      # try to search by Student Number
      if student_params[:student_number].present? && student_params[:student_number].size > 0
        student = Student.where(student_number: student_params[:student_number]).first
      end

      # try to search by Student name
      if student.nil?
        student = Student.arel_table
        student = Student.where(student[:full_name].matches("%#{student_name}%")).first
      end

      # Stil not found create new Student
      if student.nil?
        student = Student.new(full_name: student_name, student_number: student_params[:student_number])
        # Detect Gender from prefix
        if ['ด.ช.','เด็กชาย','master'].any? { |word| student_params[:full_name].downcase.include?(word) }
          student.gender_id = Gender.find_by_name("Male").id
        elsif ['ด.ญ.','เด็กหญิง','miss'].any? { |word| student_params[:full_name].downcase.include?(word) }
          student.gender_id = Gender.find_by_name("Female").id
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
      invoice_hash[:school_year] = SchoolSetting.school_year
      invoice = Invoice.new(invoice_hash)
      invoice.parent_id = parent.id
      invoice.student_id = student.id
      invoice.user_id = current_user.id
      invoice.grade_name = grade.name
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
    student_prefix = ""
    student_prefix = "ด.ช." if @invoice.student && @invoice.student.gender && @invoice.student.gender.name == "Male"
    student_prefix = "ด.ญ." if @invoice.student && @invoice.student.gender && @invoice.student.gender.name == "Female"

    student_nickname = ""
    student_nickname = " (#{@invoice.student.nickname})" if @invoice.student && @invoice.student.nickname
    student_display_name = "#{student_prefix} #{@invoice.student.full_name}#{student_nickname}"
    grade_name = @invoice.grade_name ? (@invoice.grade_name) : ""
    if @invoice.student && @invoice.student.classroom && @invoice.student.classroom.size > 0
      grade_name << " (#{@invoice.student.classroom})"
    end

    school = School.first
    slip_info = {
      header: school.invoice_header,
      footer: school.invoice_footer,
      logo: school.logo.url(:medium),
      slip_id: @invoice.id,
      thai_now_date: I18n.l(@invoice.created_at, format: "%d %B #{@invoice.created_at.year + 543}"),
      eng_now_date: @invoice.created_at.strftime("%d %B %Y"),
      semester: @invoice.semester,
      school_year: @invoice.school_year,
      school_year_thai: (@invoice.school_year.to_i - 543).to_s,
      payment_methods: [],
      grade_name: grade_name,
      receiver_name: @invoice.user.name,
      parent: {
        display_name: @invoice.parent.full_name
      },
      student: {
        display_name: student_display_name,
        student_number: @invoice.student.student_number
      }
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
    slip_info["total_amount_thai"] = ""

    render json: slip_info, status: :ok
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

  private
    def get_invoices(grade_select, search_keyword, page)
      if grade_select.downcase == 'all'
        # @invoices = Invoice.order("id DESC").to_a
        # @invoices = Invoice.order("id DESC").search(params[:search]).all.page(params[:page]).to_a
        @invoices = Invoice.search(search_keyword)
                           .order("id DESC")
                           .paginate(page: page, per_page: 10)
                           .to_a
      else
        # @invoices = Invoice.where(grade_name: grade_select).order("id DESC").to_a
        # @invoices = Invoice.where(grade_id: grade.id).order("id DESC").search(params[:search]).page(params[:page]).to_a
        grade = Grade.where(name: grade_select).first
        @invoices = Invoice.search(search_keyword)
                           .where(grade_name: grade.name)
                           .order("id DESC")
                           .paginate(page: page, per_page: 10)
                           .to_a
      end
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
