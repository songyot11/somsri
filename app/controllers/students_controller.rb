class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy], unless: :is_api?
  before_action :authenticate_user!, unless: :is_api?


  def is_api?
    !params[:pin].blank?
  end

  # GET /students
  # GET /students.json
  def index

    if params[:pin]
      user = get_current_user(params[:pin])
      if user
        render json: Student.where({ school_id: user.school.id  })
      else
        render json: { errors: "Invalid token or user not registered" }, status: 422 and return
      end
    else
      grade_select = (params[:grade_select] || 'All')
      if !params[:student_report]
        if grade_select.downcase == 'all'
          @students = Student.order("student_number ASC").search(params[:search]).all.page(params[:page]).to_a
        else
          grade = Grade.where(name: grade_select).first
          @students = Student.where(grade_id: grade.id).order("classroom ASC, classroom_number ASC").search(params[:search]).page(params[:page]).to_a
        end
      else
        if grade_select.downcase == 'all'
          @students = Student.all.order("grade_id ASC , classroom_number ASC").to_a
        else
          grade = Grade.where(name: grade_select).first
          @students = Student.where(grade_id: grade.id).order("classroom_number ASC").to_a
        end
      end
      @filter_grade = grade_select
      render "students/index", layout: "application_invoice"
    end
  end

  # GET /students/1
  # GET /students/1.json
  def show
    if params[:pin]
      user = get_current_user(params[:pin])
      if user
        render json: Student.where({ student_number: params[:id], school_id: user.school.id })
      else
        render json: { errors: "Invalid token or user not registered" }, status: 422 and return
      end
    else
      render "students/show", layout: "application_invoice"
    end
  end

  # GET /students/new
  def new
    @student = Student.new
    @parents = Parent.all
    @relations = Relationship.all

    render "students/new", layout: "application_invoice"
  end

  # GET /students/1/edit
  def edit
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
        format.html { redirect_to @student, notice: 'Student was successfully created.' }
        format.json { render :show, status: :created, location: @student }
      else
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
        format.html { redirect_to @student, notice: 'Student was successfully updated.' }
        format.json { render :show, status: :ok, location: @student }
      else
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
      format.html { redirect_to students_url, notice: 'Student was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /get_roll_calls
  def get_roll_calls
    user = get_current_user(params[:pin])
    if user && user.lists && user.lists.size > 0
      # select list
      list = user.lists[0]
      render json: list.get_students and return
    else
      render json: { errors: "Invalid token or user not registered" }, status: 422 and return
    end
  end

  def info
    user = get_current_user(params[:pin])
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
      render json: { errors: "Invalid token or user not registered" }, status: 422 and return
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.includes([:parents, :relationships]).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.require(:student).permit(:full_name, :full_name_english, :nickname, :nickname_english, :gender_id, :birthdate, :grade_id, :classroom, :classroom_number, :student_number, :national_id, :remark)
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
