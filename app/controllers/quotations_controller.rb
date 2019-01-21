class QuotationsController < ApplicationController
  load_and_authorize_resource

  def index
    quotations_filter

    @quotations = @quotations.paginate(page: params[:page], per_page: 10)

    methods = %i[student_name quotator_name grade_name total_amount paid_at
                 outstanding_balance]
    render json: {
      quotations: @quotations.as_json(methods: methods),
      current_page: @quotations.current_page,
      total_records: @quotations.total_entries
    }
  end

  def show
    @lineItems = LineItem.where(quotation_id: params[:id])
    @student = @quotation&.student
    @parent = @quotation&.parent
    @payment_date_start =  @quotation&.payment_date_start&.strftime("%Y/%m/%d")
    @payment_date_end =  @quotation&.payment_date_end&.strftime("%Y/%m/%d")
    render json: {
      quotation: @quotation,
      lineItems: @lineItems,
      student: @student,
      parent: @parent,
      payment_date_start: @payment_date_start,
      payment_date_end: @payment_date_end
    }
  end

  def create
    grade = Grade.find_by_name(params["quotations"]["grade_name"]["value"])

    Quotation.transaction do
      parent = Parent.find_or_create_by(parent_params);
      student = nil
      students = Student.all
      # Clean Up Student's name
      student_name = Student.clean_full_name(student_params[:full_name])

      # try to search by Student Number
      if student_params[:student_number].present? &&
        student_params[:student_number].size > 0 &&
        (student_params[:student_number].is_a? Integer) &&
        student_params[:student_number] > 0
        students = students.where(student_number: student_params[:student_number])
      end

      # try to search by Student name
      if student_name.present? && student_name.size > 0
        students = students.where(full_name: student_name).or(
          Student.where(full_name_english: student_name))
      end

      student = students.first

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
      student.save # student Save

      if student.parents.size == 0 || student.parents.select{|p| p.full_name == parent.full_name}.size == 0
        StudentsParent.create(student_id: student.id, parent_id: parent.id, relationship_id: 2)
      end

      quotation_hash = quotation_params
      quotation_hash.delete(:items)
      quotation_hash.delete(:grade)
      quotation_hash.delete(:grade_name)

      if quotation_hash[:school_year].blank?
        quotation_hash[:school_year] = SchoolSetting.school_year
      end

      quotation_new = Quotation.new(quotation_hash)
      quotation_new.parent_id = parent.id
      quotation_new.parent_name = parent.full_name
      quotation_new.student_id = student.id
      quotation_new.student_name = student.invoice_screen_full_name_display
      quotation_new.user_id = current_user.id
      quotation_new.user_name = current_user.name
      quotation_new.grade_name = grade.name
      quotation_new.quotation_status = 0

      line_item_params.to_h[:items].each do |item|
        quotation_new.line_items << LineItem.new(item)
      end

      quotation_new.save
      render json: { id: quotation_new.id }, status: :ok
    end
  end

  def bill
    grade_name = @quotation.grade_name ? (@quotation.grade_name) : ""

    school = School.first
    bill_info = {
      header: school.invoice_header_with_logo,
      footer: school.invoice_footer,
      logo: school.logo_url,
      slip_id: @quotation.id,
      thai_now_date: I18n.l(@quotation.created_at, format: "%d %B #{@quotation.created_at.year + 543}"),
      eng_now_date: @quotation.created_at.strftime("%d %B %Y"),
      semester: @quotation.semester,
      school_year: @quotation.school_year,
      school_year_en: (@quotation.school_year.to_i - 543).to_s,
      create_year: @quotation.created_at.year + 543,
      payment_methods: [],
      remark: @quotation.remark,
      grade_name: grade_name,
      receiver_name: @quotation.user.name,
      payment_date_start: @quotation&.payment_date_start&.strftime("%d/%m/%Y"),
      payment_date_end: @quotation&.payment_date_end&.strftime("%d/%m/%Y"),
      parent: {
        display_name: @quotation.parent.full_name
      },
      student: {
        display_name: @quotation.student_name,
        student_number: @quotation.student.student_number
      },
      display_schools_year_with_invoice_id: SiteConfig.get_cache.display_schools_year_with_invoice_id,
      banks: Bank.all
    }

    line_items = []
    total = 0
    @quotation.line_items.each do |line_item|
      total += line_item.amount
      line_items << {
        detail: line_item.detail,
        amount: line_item.amount,
      }
    end

    bill_info["line_items"] = line_items if line_items.length > 0
    bill_info["total_amount"] = total

    respond_to do |format|
      format.html do
        render json: bill_info, status: :ok
      end
      format.pdf do
        @results = bill_info
        render pdf: "file_name",
                template: "pdf/bill.html.erb",
                encoding: "UTF-8",
                layout: 'pdf.html',
                show_as_html: params[:show_as_html].present?
      end
    end
  end

  private

  def quotations_filter
    start_date = params[:start_date]
    start_date = DateTime.parse(start_date).beginning_of_day if isDate(start_date)

    end_date = params[:end_date]
    end_date = DateTime.parse(end_date).end_of_day if isDate(end_date)

    data_field = Quotation.arel_table[:created_at]
    @quotations = qry_date_range(@quotations, data_field, start_date, end_date)

    keyword = params[:keyword]
    if keyword.present?
      keyword = "%#{keyword}%"
      @quotations = @quotations.where('CAST(id as text) LIKE ?', keyword)
    end
  end

  def quotation_params
    params.require(:quotations).permit(:student_id, :parent_id, :user_id, :invoice_id, :quotation_status, :remark, :school_year, :semester, :grade_name, :student_name, :parent_name, :user_name, :payment_date_start, :payment_date_end)
  end

  def parent_params
    params.require(:parent).permit(:full_name, :full_name_english, :nickname, :nickname_english, :mobile, :email, :line_id)
  end

  def student_params
    params.require(:student).permit(:full_name, :full_name_english, :nickname, :nickname_english, :gender_id, :birthdate, :grade_id, :classroom, :classroom_number, :student_number, :national_id, :remark)
  end

  def line_item_params
    params.require(:quotations).permit(items: [[:detail, :amount]])
  end
  
end
