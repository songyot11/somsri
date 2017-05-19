class StudentsController < ApplicationController
  before_action :set_student, only: [:edit, :update, :destroy], unless: :is_api?
  before_action :authenticate_user!, unless: :is_api?
  load_and_authorize_resource except: [:index, :get_roll_calls, :info]

  def is_api?
    !params[:pin].blank?
  end

  # GET /students
  # GET /students.json
  def index
    @menu = "นักเรียน"
    authorize! :read, Student
    grade_select = (params[:grade_select] || 'All')
    class_select = (params[:class_select] || 'All')
    @class_display = Student.with_deleted.order("classroom ASC").select(:classroom).map(&:classroom).uniq.compact
    year_select = (params[:year_select] || Date.current.year + 543)
    semester_select = params[:semester_select]
    invoice_status = params[:status]

    if !params[:student_report]
      # without angular
      if grade_select.downcase == 'all' && class_select.downcase == 'all'
        students = Student.with_deleted
      elsif grade_select.downcase == 'all' && class_select.downcase != 'all'
        students = Student.with_deleted.where(classroom: class_select)
      elsif grade_select != 'all' && class_select.downcase == 'all'
        grade = Grade.where(name: grade_select).first
        students = Student.with_deleted.where(grade: grade.id)
      elsif grade_select != 'all' && class_select != 'all'
        grade = Grade.where(name: grade_select).first
        students = Student.with_deleted.where(grade: grade.id , classroom: class_select)
      end
      @students = students.order("deleted_at DESC , classroom ASC, classroom_number ASC").search(params[:search]).page(params[:page]).to_a
    else
      # with angular
      if grade_select.downcase == 'all'
        @students_all = Student.order("deleted_at DESC , student_number ASC").search(params[:search]).with_deleted.to_a
      else
        grade = Grade.where(name: grade_select).first
        @students_all = Student.where(grade_id: grade.id).order("classroom ASC, classroom_number ASC").search(params[:search]).to_a
      end

      student_index = Array.new
      @students_all.each_with_index do |student, index|
        # if (!student.all_active_invoice_year.include?(year_select) || student.active_invoice_semester != semester_select) || (student.active_invoice_tuition_fee == nil)
        if !student.is_active_invoice_year_semester(year_select, semester_select)
          student.active_invoice_status = "ยังไม่ได้ชำระ"
        else
          student_index.push(index)
        end
      end

      if invoice_status == "unpaid"
        shift = 0
        student_index.each do |index|
          @students_all.delete_at(index-shift)
          shift += 1
        end
      end

      @students = @students_all.paginate(:page => params[:page], :per_page => 10)
    end

    @filter_grade = grade_select
    @filter_class = class_select
    render "students/index", layout: "application_invoice"
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
      flash[:success] = "ลบนักเรียนเรียบร้อยแล้ว"
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
      render json: list.get_students and return
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
