class StudentsController < ApplicationController
  before_action :set_student, only: [:edit, :update, :destroy], unless: :is_api?
  before_action :authenticate_user!, unless: :is_api?
  load_and_authorize_resource except: [:index, :get_roll_calls, :info]

  def is_api?
    !params[:pin].blank?
  end

  def student_report
    grade_select = (params[:grade_select] || 'All')
    class_select = (params[:class_select] || 'All')
    year_select = (params[:year_select] || Date.current.year + 543)
    semester_select = params[:semester_select]
    invoice_status = params[:status]
    student_index = Array.new
    if grade_select.downcase == 'all'
      @students_all = Student.order("student_number ASC").search(params[:search]).with_deleted.to_a
    else
      grade = Grade.where(name: grade_select).first
      @students_all = Student.where(grade_id: grade.id).order("classroom ASC, classroom_number ASC").search(params[:search]).with_deleted.to_a
    end

    datas = []
    total_tuition = 0.0
    total_other = 0.0
    total_amount = 0.0
    @students_all.each_with_index do |student, index|
      paid = false
      tuition_fee = 0.0
      other_fee = 0.0
      total_fee = 0.0
      payment_method = ""
      last_tuition_invoice = nil
      qry_invoice = Invoice.where(student_id: student.id, school_year: year_select, invoice_status_id: InvoiceStatus.status_active_id)
      if semester_select == "อื่นๆ"
        qry_invoice = qry_invoice.where.not(semester: SchoolSetting.semesters)
      else
        qry_invoice = qry_invoice.where(semester: semester_select)
      end
      invoices = qry_invoice.order("updated_at ASC").to_a

      #skip student no invoice and deleted
      next if invoices.count == 0 && student.deleted_at

      invoices.each do |invoice|
        invoice.line_items.each do |item|
          if item.detail =~ /Tuition Fee/
            tuition_fee += item.amount
            paid = true
          else
            other_fee += item.amount
          end
          total_fee += item.amount
        end
        last_tuition_invoice = invoice
        payment_method = invoice.payment_methods.collect{ |pm| pm.payment_method }.join(',')
      end

      data = {
        id: student.id,
        classroom_number: student.classroom_number,
        student_number: student.student_number,
        grade_name: last_tuition_invoice ? last_tuition_invoice.grade_name : student.grade_name,
        parent_names: student.parent_names,
        active_invoice_status: paid ? "ชำระแล้ว" : "ยังไม่ได้ชำระ",
        active_invoice_payment_method: payment_method,
        active_invoice_tuition_fee: tuition_fee,
        active_invoice_other_fee: other_fee,
        active_invoice_total_amount: total_fee,
        full_name_with_title: student.full_name_with_title,
        nickname_eng_thai: student.nickname_eng_thai,
        active_invoice_updated_at: last_tuition_invoice ? last_tuition_invoice.updated_at : nil,
        deleted_at: student.deleted_at
      }

      if invoice_status == "unpaid" && !paid
        total_tuition += tuition_fee
        total_other += other_fee
        total_amount += total_fee
        datas << data
      elsif invoice_status == "paid" && paid
        total_tuition += tuition_fee
        total_other += other_fee
        total_amount += total_fee
        datas << data
      elsif invoice_status.blank? || invoice_status == "all"
        total_tuition += tuition_fee
        total_other += other_fee
        total_amount += total_fee
        datas << data
      end
    end

    if !params[:all]
      datas = datas.paginate(:page => params[:page], :per_page => 10)
      render json: {
        datas: datas,
        current_page: datas.current_page,
        total_records: datas.total_entries,
        other_fee: total_other,
        tuition_fee: total_tuition,
        amount: total_amount
        }, status: :ok
      else
        render json: {
          datas: datas,
          other_fee: total_other,
          tuition_fee: total_tuition,
          amount: total_amount
          }, status: :ok
        end


      end

  # GET /students
  # GET /students.json
  def index
    @menu = "นักเรียน"
    authorize! :read, Student

    grade_select = (params[:grade_select] || 'All')
    class_select = (params[:class_select] || 'All')

    @class_display = Student.order("classroom ASC").select(:classroom).map(&:classroom).uniq.compact
    year_select = (params[:year_select] || Date.current.year + 543)
    semester_select = params[:semester_select]
    invoice_status = params[:status]

    # without angular
    if grade_select.downcase == 'all' && class_select.downcase == 'all'
      students = Student
    elsif grade_select.downcase == 'all' && class_select.downcase != 'all'
      students = Student.where(classroom: class_select)
    elsif grade_select != 'all' && class_select.downcase == 'all'
      grade = Grade.where(name: grade_select).first
      students = Student.where(grade: grade.id)
    elsif grade_select != 'all' && class_select != 'all'
      grade = Grade.where(name: grade_select).first
      students = Student.where(grade: grade.id , classroom: class_select)
    end

    if params[:for_print]
      @students = students.order("grade_id ASC, classroom ASC, classroom_number ASC, student_number ASC").search(params[:search]).to_a
    else
      @students = students.order("deleted_at DESC , classroom ASC, classroom_number ASC").search(params[:search]).page(params[:page]).to_a
    end

    @filter_grade = grade_select
    @filter_class = class_select

    if params[:for_print]
      results = {
        school_year: SchoolSetting.school_year_or_default(".........."),
        student_list: []
      }
      @students.to_a.each do |student|
        results[:student_list] << {
          student_number: student.student_number || "",
          full_name: student.full_name_with_title || "",
          national_id: student.national_id || "",
          birthdate: student.birthdate ? (student.birthdate + 543.years).strftime("%d/%m/%Y") : ""
        }
      end
      render json: results, status: :ok
    else
      respond_to do |f|
        f.html { render "students/index", layout: "application" }
        f.json {
          @students = students.search(params[:search]).order("#{params[:sort]} #{params[:order]}")
          render json: {
            total: @students.count,
            rows: @students.limit(params[:limit]).offset(params[:offset]).as_json('index')
          }
        }
      end
    end

  end

  # GET /students/new
  def new
    @menu = "นักเรียน"
    @student = Student.new
    @parents = Parent.all
    @relations = Relationship.all
    render "students/new", layout: "application_invoice"
  end

  # GET /students/1/edit
  def edit
    @menu = "นักเรียน"
    @parents = Parent.all
    @relations = Relationship.all

    render "students/edit", layout: "application_invoice"
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(student_params)
    @student.full_name = student_params[:full_name].gsub('ด.ช.', '').gsub('ด.ญ.', '').gsub('เด็กหญิง', '').gsub('เด็กชาย', '').gsub("ดช" , '').gsub('ดญ' , '')
    parent_assign
    if @student.save
      relation_assign
      respond_to do |format|
        format.html do
          flash[:success] = "เพิ่มนักเรียนเรียบร้อยแล้ว"
          redirect_to students_url
        end
        format.json { render :show, status: :created, location: @student }
      end
    else
      @relations = Relationship.all
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students/1
  # PATCH/PUT /students/1.json
  def update
    parent_assign
    respond_to do |format|
      if @student.update(student_params)
        relation_assign
        format.html do
          flash[:success] = "แก้ไขข้อมูลนักเรียนเรียบร้อยแล้ว"
          redirect_to students_url
        end
        format.json { render :show, status: :ok, location: @student }
      else
        @relations = Relationship.all
        format.html { render :edit }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1
  # DELETE /students/1.json
  def destroy
    @student.destroy
    respond_to do |format|
      format.html { redirect_to students_url }
      format.json { head :no_content }
    end
  end

  def real_destroy
    begin
      @student = Student.find(params[:student_id])
      @student.really_destroy!
      flash[:denger] = "ลบนักเรียนเรียบร้อยแล้ว"
    rescue ActiveRecord::DeleteRestrictionError => e
      @student.errors.add(:base, e)
      flash[:error] = "#{e}"
    ensure
      respond_to do |format|
        format.html { redirect_to students_url}
        format.json { head :no_content }
      end
    end
  end

  def graduate
    if @student = Student.find(params[:student_id]).update(deleted_at: Time.now , status: 'จบการศึกษา')
      respond_to do |format|
        format.html { redirect_to students_url }
        format.json { head :no_content }
      end
    end
  end

  def resign
    if @student = Student.find(params[:student_id]).update(deleted_at: Time.now , status: 'ลาออก')
      respond_to do |format|
        format.html { redirect_to students_url }
        format.json { head :no_content }
      end
    end
  end

  def restore
    if @student = Student.restore(params[:student_id])
      @student = Student.unscoped.find(params[:student_id]).update(status: 'กำลังศึกษา')
      respond_to do |format|
        format.html { redirect_to students_url }
        format.json { head :no_content }
      end
    end
  end

  # GET /get_roll_calls
  def get_roll_calls
    employee = Employee.where(pin: params[:pin]).first
    if employee && employee.lists && employee.lists.size > 0
      # select list
      list = employee.lists[0]
      render json: list.get_students.as_json('roll_call') and return
    else
      render json: { errors: "Invalid token or user not registered" }, status: 422 and return
    end
  end

  def info
    employee = Employee.where(pin: params[:pin]).first
    if employee
      student = Student.find_by(code: params[:id])
      d =  Date.strptime(params[:date], "%Y-%m-%d")
      if student
        s_rollcall = student.roll_call
        if s_rollcall
          date = d
          @studet_r = []
          @morning = []
          @afternoon = []

          roll_date_1 = s_rollcall.where(check_date:date.strftime("%Y-%m-%d"))
          @studet_r << roll_date_1 if roll_date_1

          morning  = s_rollcall.where(check_date:date.strftime("%Y-%m-%d"), round:"morning")
          @morning  << morning if morning
          afternoon = s_rollcall.where(check_date:date.strftime("%Y-%m-%d"), round:"afternoon")
          @afternoon << afternoon if afternoon

          (1..Time.days_in_month(d.month)).each do |i|
            date = d + i.days
            roll_date = s_rollcall.where(check_date:date.strftime("%Y-%m-%d"))
            @studet_r << roll_date if roll_date
              #do count rollcall status
              morning  = s_rollcall.where(check_date:date.strftime("%Y-%m-%d"), round:"morning")
              @morning  << morning if morning
              afternoon = s_rollcall.where(check_date:date.strftime("%Y-%m-%d"), round:"afternoon")
              @afternoon << afternoon if afternoon
            end
          end
          result = []
          result << {
            date: d,
            first_name: student.first_name,
            last_name: student.last_name,
            prefix: student.prefix,
            morning: @morning.flatten,
            afternoon: @afternoon.flatten
          }

          render json: result
        else
          render json: { errors: "Invalid student code" }, status: 422 and return
        end
      else
        render json: { errors: "Invalid PIN" }, status: 422 and return
      end
    end

  # GET /invoice_total_amount
  def invoice_total_amount
    grade_select = (params[:grade_select] || 'All')
    year_select = (params[:year_select] || Date.current.year + 543)
    semester_select = (params[:semester_select] || nil)
    invoice_status = params[:status]

    @students = Student
    if grade_select.downcase == 'all'
      @students = @students.search(params[:search]).all.to_a
    else
      grade = Grade.where(name: grade_select).first
      @students = @students.where(grade_id: grade.id).search(params[:search]).to_a
    end

    other_fee = 0
    tuition_fee = 0
    amount = 0

    if invoice_status != "unpaid"
      @students.each do |student|
        if student.is_active_invoice_year_semester(year_select, semester_select)
          other_fee += student.active_invoice_other_fee if !student.active_invoice_other_fee.blank?
          tuition_fee += student.active_invoice_tuition_fee if !student.active_invoice_tuition_fee.blank?
          amount += student.active_invoice_total_amount if !student.active_invoice_total_amount.blank?
        end
      end
    end
    render json: [{other_fee: other_fee, tuition_fee: tuition_fee, amount: amount}], status: :ok
  end

  def upload_photo
    @student = Student.where(id: params[:id]).update( upload_photo_params )
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.includes([:parents, :relationships]).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.require(:student).permit(:full_name, :full_name_english, :nickname, :nickname_english, :gender_id, :birthdate, :grade_id, :classroom, :classroom_number, :student_number, :national_id, :remark , :status, :img_url)
    end

    def relation_assign
      @student.parents.clear
      @student.parents << @parents
      @parents.each_with_index do |parent, index|
        std_parent = StudentsParent.find_by_student_id_and_parent_id(@student.id, parent.id)
        std_parent.relationship_id = @relationships[index]
        std_parent.save
      end
    end

    def parent_assign
      parent_params = params[:parent]
      relation_params = params[:relationship]
      @parents = Array.new
      @relationships = Array.new
      return unless parent_params
      return unless relation_params
      parent_relation = Hash.new
      if !parent_params.nil?
        parent_params.each_with_index do |value, index|
          parent_relation[value] = relation_params[index]
        end
      end
      parent_params = parent_relation.keys
      @relationships = parent_relation.values
      if !parent_params.nil?
        parent_params.each_with_index.map do |p, index|
          if p.to_i != 0
            begin
              prn = Parent.find(p)
            rescue
              prn = Parent.find_or_create_by(full_name: p)
            end
            @parents.push(prn)
          elsif p.length > 0 && p.to_i == 0
            new_prn = Parent.find_or_create_by(full_name: parent_params[index])
            @parents.push(new_prn)
          end
        end
      end
    end

    def upload_photo_params
      params.require(:student).permit(:img_url)
    end
  end
