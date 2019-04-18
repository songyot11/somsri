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
      @students_all = Student.where(grade_id: grade.id).order("classroom_id ASC, classroom_number ASC").search(params[:search]).with_deleted.to_a
    end

    datas = []
    total_tuition = 0.0
    total_other = 0.0
    total_amount = 0.0
    total_year = 0.0
    @students_all.each_with_index do |student, index|
      paid = false
      tuition_fee = 0.0
      other_fee = 0.0
      total_fee = 0.0
      year_fee = 0.0
      payment_method = ""
      last_tuition_invoice = nil
      qry_invoice = Invoice.where(student_id: student.id, school_year: year_select, invoice_status_id: InvoiceStatus.status_active_id)
      invoices = qry_invoice.order("created_at ASC").to_a

      #skip student no invoice and deleted
      next if invoices.count == 0 && student.deleted_at

      semester_exclude = []
      if semester_select == "อื่นๆ"
        semester_exclude = SchoolSetting.semesters
      else
        semester_exclude = SchoolSetting.semesters - [semester_select.to_s]
      end

      invoices.each do |invoice|
        invoice.line_items.each do |item|
          if !semester_exclude.include?(invoice.semester)
            if item.detail =~ /(Tuition Fee)|(ค่าธรรมเนียมการศึกษา)/
              tuition_fee += item.amount
              paid = true
            else
              other_fee += item.amount
            end
            total_fee += item.amount
          end
          year_fee += item.amount
        end
        last_tuition_invoice = invoice
        payment_method = invoice.payment_methods.collect{ |pm| pm.payment_method }.join(',') if !semester_exclude.include?(invoice.semester)
      end


      data = {
        id: student.id,
        classroom_number: student.classroom_number,
        student_number: student.student_number,
        grade_name: last_tuition_invoice ? last_tuition_invoice.grade_name : student.grade_name,
        classroom: student.classroom ? student.classroom.name : "",
        parent_names: student.parent_names,
        active_invoice_status: paid ? "ชำระแล้ว" : "ยังไม่ได้ชำระ",
        active_invoice_payment_method: payment_method,
        active_invoice_tuition_fee: tuition_fee,
        active_invoice_year_fee: year_fee,
        active_invoice_other_fee: other_fee,
        active_invoice_total_amount: total_fee,
        full_name_with_title: student.invoice_screen_full_name_display,
        nickname_eng_thai: student.nickname_eng_thai,
        active_invoice_created_at: last_tuition_invoice ? last_tuition_invoice.created_at : nil,
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
      total_year += year_fee
    end

    if !params[:all]
      datas = datas.paginate(:page => params[:page], :per_page => 10)
      render json: {
        datas: datas,
        current_page: datas.current_page,
        total_records: datas.total_entries,
        other_fee: total_other,
        tuition_fee: total_tuition,
        total_year: total_year,
        amount: total_amount
      }, status: :ok
    else
      render json: {
        datas: datas,
        other_fee: total_other,
        tuition_fee: total_tuition,
        amount: total_amount,
        total_year: total_year
      }, status: :ok
    end
  end

  # GET /students
  # GET /students.json
  # GET /students.pdf
  def index
    @menu = t('student')
    authorize! :read, Student

    grade_select = (params[:grade_select] || 'All')
    class_select = (params[:class_select] || 'All')

    @class_display = Classroom.order("id ASC").select(:name).map(&:name).uniq.compact
    year_select = (params[:year_select] || Date.current.year + 543)
    semester_select = params[:semester_select]
    invoice_status = params[:status]

    # without angular
    if grade_select.downcase == 'all' && class_select.downcase == 'all'
      students = Student
    elsif grade_select.downcase == 'all' && class_select.downcase != 'all'
      classroom = Classroom.where(name: class_select).first
      students = Student.where(classroom_id: classroom.id)
    elsif grade_select.downcase != 'all' && class_select.downcase == 'all'
      grade = Grade.where(name: grade_select).first
      students = Student.where(grade: grade.id)
    elsif grade_select.downcase != 'all' && class_select.downcase != 'all'
      grade = Grade.where(name: grade_select).first
      classroom = Classroom.where(name: class_select).first
      students = Student.where(grade: grade.id , classroom_id: classroom.id)
    end
    @students = students.order("#{params[:sort]} #{params[:order]}").search(params[:search])
    @filter_grade = grade_select
    @filter_class = class_select

    if params[:for_print]
      results = {
        school_year: SchoolSetting.school_year_or_default(".........."),
        student_list: []
      }

      @students.to_a.each do |student|
        parents = []
        student.parent_and_relationship_names.each_with_index do |parent, i|
          break if i > 1
          parents << parent
        end
        student_img_url = ""
        if student.img_url.exists?
          if Paperclip::Attachment.default_options[:storage] == :s3
            student_img_url = student.img_url.expiring_url(10, :medium)
          elsif Paperclip::Attachment.default_options[:storage] == :filesystem
            student_img_url = student.img_url.path(:medium)
          end
        end

        results[:student_list] << {
          student_number: student.student_number || "",
          nickname: student.nickname,
          img_url:  student_img_url,
          full_name: student.full_name_with_title || "",
          national_id: student.national_id || "",
          birthdate: student.birthdate ? (student.birthdate + 543.years).strftime("%d/%m/%Y") : "",
          parents: parents
        }
      end

      respond_to do |format|
        format.html
        format.json do
          render json: results, status: :ok
        end
        format.pdf do
          size = 10
          @results = {
            dataPerPages: results[:student_list].each_slice(size).to_a,
            school_year: results[:school_year]
          }
          render pdf: "file_name",
                  template: "students/student_list_with_image.html.erb",
                  encoding: "UTF-8",
                  layout: 'pdf.html',
                  show_as_html: params[:html_view].present?
        end
      end
    elsif params[:autocomplete]
      @students.to_a
      render json: @students.limit(10).as_json('autocomplete'), status: :ok
    else
      @students.to_a
      respond_to do |f|
        f.html { render "students/index", layout: "application_invoice" }
        f.json {
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
    @menu = t('student')
    @student = Student.new
    @parents = Parent.all
    @relations = Relationship.all
    render "students/new", layout: "application_invoice"
  end

  # GET /students/1/edit
  def edit
    @menu = t('student')
    @parents = Parent.all
    @relations = Relationship.all

    render "students/edit", layout: "application_invoice"
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(student_params)
    parent_assign
    if @student.save
      relation_assign
      respond_to do |format|
        format.html do
          flash[:notice] = {
            type: "alert",
            message: I18n.t('student_info_success_save')
          }
          redirect_to students_url
        end
        format.json { render :show, status: :created, location: @student }
      end
    else
      @relations = Relationship.all
      flash[:error] = {
        type: "panel",
        message: flash_message_list(@student.errors.full_messages.uniq),
        title: I18n.t('student_info_cannot_save')
      }
      respond_to do |format|
        format.html { redirect_to new_student_path }
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
          flash[:notice] = {
            type: "alert",
            message: I18n.t('student_info_success_save')
          }
          redirect_to students_url
        end
        format.json { render :show, status: :ok, location: @student }
      else
        @relations = Relationship.all
        flash[:error] = {
          type: "panel",
          message: flash_message_list(@student.errors.full_messages.uniq),
          title: I18n.t('student_info_cannot_save')
        }
        format.html { redirect_to edit_student_path }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1
  # DELETE /students/1.json
  def destroy
    @student.destroy
    flash[:notice] = {
      type: "alert",
      message: I18n.t('student_delete_success')
    }
    respond_to do |format|
      format.html { redirect_to students_path }
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

  # /students/:id/graduate
  def graduate
    @student = Student.find(params[:id]).graduate
    flash[:notice] = {
      type: "alert",
      message: I18n.t('student_graduated_success')
    }
    respond_to do |format|
      format.html { redirect_to students_path }
      format.json { head :no_content }
    end
  end

  # /students/:id/resign
  def resign
    @student = Student.find(params[:id]).resign
    flash[:notice] = {
      type: "alert",
      message: I18n.t('student_resigned_success')
    }
    respond_to do |format|
      format.html { redirect_to students_path }
      format.json { head :no_content }
    end
  end

  #POST /students/restore
  def restore
    Student.with_deleted.where(id: params[:student_id]).first.restore_recursively
    respond_to do |format|
      format.html { redirect_to students_url }
      format.json { head :no_content }
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

  def create_by_name
    fullname = params[:fullname]
    nickname = params[:nickname]

    splited = fullname.split(" ")

    gender_id = nil
    gender_id = Gender.female.id if ["เด็กหญิง", "ด.ญ.", "miss"].include?(splited[0].downcase)
    gender_id = Gender.male.id if ["เด็กชาย", "ด.ช.", "master"].include?(splited[0].downcase)

    student = Student.create({
      gender_id: gender_id,
      full_name: fullname,
      nickname: nickname
    })

    result = {
      img: student.img_url.exists? ? student.img_url.expiring_url(10, :medium) : nil,
      name: student.invoice_screen_full_name_display,
      id: student.id
    }
    render json: result, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.includes([:parents, :relationships]).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.require(:student).permit(:full_name, :full_name_english, :nickname, :nickname_english, :gender_id, :birthdate, :grade_id, :classroom_id, :classroom_number, :student_number, :national_id, :remark , :status, :img_url, :nationality)
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
      mobile = params[:mobile]
      email = params[:email]
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
            if mobile
              prn.mobile = mobile[index]
              prn.save
            end
            if email
              prn.email = email[index]
              prn.save
            end
            @parents.push(prn)
          elsif p.length > 0 && p.to_i == 0
            new_prn = Parent.find_or_create_by(full_name: parent_params[index], mobile: mobile[index], email: email[index])
            @parents.push(new_prn)
          end
        end
      end
    end

    def upload_photo_params
      params.require(:student).permit(:img_url)
    end
  end
