class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy], unless: :is_api?
  before_action :authenticate_user!, unless: :is_api?
  load_and_authorize_resource except: [:index, :show, :get_roll_calls, :info]

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
    @class_display = Student.order("classroom ASC").select(:classroom).map(&:classroom).uniq.compact

    if !params[:student_report]
      # without angular
      if grade_select.downcase == 'all' && class_select.downcase == 'all'
        students = Student.with_deleted
      elsif grade_select.downcase == 'all' && class_select.downcase != 'all'
        students = Student.where(classroom: class_select)
      elsif grade_select != 'all' && class_select.downcase == 'all'
        grade = Grade.where(name: grade_select).first
        students = Student.where(grade: grade.id)
      elsif grade_select != 'all' && class_select != 'all'
        grade = Grade.where(name: grade_select).first
        students = Student.where(grade: grade.id , classroom: class_select)
      end
      @students = students.order("classroom ASC, classroom_number ASC").search(params[:search]).page(params[:page]).to_a
    else
      # with angular
      if grade_select.downcase == 'all'
        @students = Student.order("deleted_at DESC , student_number ASC").search(params[:search]).with_deleted.paginate(page: params[:page], per_page: 10).to_a
      else
        grade = Grade.where(name: grade_select).first
        @students = Student.where(grade_id: grade.id).order("classroom ASC, classroom_number ASC").search(params[:search]).paginate(page: params[:page], per_page: 10).to_a
      end
    end

    @filter_grade = grade_select
    @filter_class = class_select
    render "students/index", layout: "application_invoice"
  end

  # GET /students/1
  # GET /students/1.json
  def show
    @menu = "นักเรียน"
    authorize! :read, Student
    render "students/show", layout: "application_invoice"
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
    parent_assign
    respond_to do |format|
      if @student.save
        relation_assign
        format.html { redirect_to @student }
        format.json { render :show, status: :created, location: @student }
      else
        @relations = Relationship.all
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
        format.html { redirect_to @student }
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
    @student = Student.find(params[:student_id])
    @student.destroy

    if @student.destroy
      @student = Student.unscoped.find(params[:student_id]).update(status: 'จบการศึกษา')
      respond_to do |format|
        format.html { redirect_to students_url }
        format.json { head :no_content }
      end
    end
  end

  def resign
    @student = Student.find(params[:student_id])
    @student.destroy

    if @student.destroy
      @student = Student.unscoped.find(params[:student_id]).update(status: 'ลาออก')
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

    @students.each do |student|
      other_fee += student.active_invoice_other_fee if !student.active_invoice_other_fee.blank?
      tuition_fee += student.active_invoice_tuition_fee if !student.active_invoice_tuition_fee.blank?
      amount += student.active_invoice_total_amount if !student.active_invoice_total_amount.blank?
    end
    render json: [{other_fee: other_fee, tuition_fee: tuition_fee, amount: amount}], status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.includes([:parents, :relationships]).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.require(:student).permit(:full_name, :full_name_english, :nickname, :nickname_english, :gender_id, :birthdate, :grade_id, :classroom, :classroom_number, :student_number, :national_id, :remark , :status)
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
      prn_params = params[:parent]
      rel_params = params[:relationship]

      prn_rel = Hash.new
      if !prn_params.nil?
        prn_params.each_with_index { |value, index| prn_rel[value] = rel_params[index] }
      end
      prn_params = prn_rel.keys
      @relationships = prn_rel.values

      @parents = Array.new
      if !prn_params.nil?
        prn_params.each_with_index.map do |p, index|
          if p.to_i != 0
            begin
            prn = Parent.find(p)
            rescue
            prn = Parent.find_or_create_by(full_name: p)
            end
            @parents.push(prn)
          elsif p.length > 0 && p.to_i == 0
            new_prn = Parent.find_or_create_by(full_name: prn_params[index])
            @parents.push(new_prn)
          end
        end
      end
    end
end
