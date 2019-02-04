class ParentsController < ApplicationController
  before_action :set_parent, only: [:edit, :update, :destroy]
  before_action :authenticate_user!
  load_and_authorize_resource
  # GET /parents
  # GET /parents.json
  def index
    students = Student.all.order("classroom_id ASC")

    grade_select = (params[:grade_select] || 'All')
    class_select = (params[:class_select] || 'All')
    @classroom_display = Classroom.order("id ASC").select(:name).map(&:name).uniq.compact
    @parents = get_parents(class_select, grade_select, params[:search], params[:page], params[:per_page], params[:sort], params[:order])

    @menu = t('parent')
    respond_to do |f|
      f.html { render "parents/index", layout: "application_invoice" }
      f.json {
        render json: {
          total: @parents.total_entries,
          rows: @parents.as_json({ index: true })
        }
      }
    end

  end

  # GET /parents/new
  def new
    @menu = t('parent')
    @parent = Parent.new
    @students = Student.all
    @relations = Relationship.all

    render "parents/new", layout: "application_invoice"
  end

  # GET /parents/1/edit
  def edit
    @menu = t('parent')
    @students = Student.all
    @relations = Relationship.all

    render "parents/edit", layout: "application_invoice"
  end

  # POST /parents
  # POST /parents.json
  def create
    @parent = Parent.new(parent_params)
    student_assign
    if @parent.save
      relation_assign
      respond_to do |format|
        format.html do
          flash[:notice] = {
            type: "alert",
            message: I18n.t('parent_info_success_save')
          }
          redirect_to parents_url
        end
        format.json { render :show, status: :created, location: @parent }
      end
    else
      @relations = Relationship.all
      flash[:error] = {
        type: "panel",
        message: flash_message_list(@parent.errors.full_messages.uniq),
        title: I18n.t('parent_info_cannot_save')
      }
      respond_to do |format|
        format.html { redirect_to new_parent_path }
        format.json { render json: @parent.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /parents/1
  # PATCH/PUT /parents/1.json
  def update
    student_assign
    respond_to do |format|
      if @parent.update(parent_params)
        relation_assign
        format.html do
          flash[:notice] = {
            type: "alert",
            message: I18n.t('parent_info_success_save')
          }
          redirect_to parents_url
        end
        format.json { render :show, status: :ok, location: @parent }
      else
        @relations = Relationship.all
        flash[:error] = {
          type: "panel",
          message: flash_message_list(@parent.errors.full_messages.uniq),
          title: I18n.t('parent_info_cannot_save')
        }
        format.html { redirect_to edit_parent_path }
        format.json { render json: @parent.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parents/1
  # DELETE /parents/1.json
  def destroy
    @parent.destroy
    flash[:notice] = {
      type: "alert",
      message: I18n.t('parent_delete_success')
    }
    respond_to do |format|
      format.html { redirect_to parents_url}
      format.json { head :no_content }
    end
  end

  def archive
    @parent = Parent.find(params[:parent_id]).update(deleted_at: Time.now)
    respond_to do |format|
      format.html { redirect_to parents_url}
      format.json { head :no_content }
    end
  end

  def restore
    Parent.with_deleted.find(params[:parent_id]).restore_recursively
    respond_to do |format|
      format.html { redirect_to parents_url}
      format.json { head :no_content }
    end
  end

  def real_destroy
    begin
      @parent = Parent.find(params[:parent_id])
      @parent.really_destroy!
      flash[:danger] = "ลบผู้ปกครองเรียบร้อยแล้ว"
    rescue ActiveRecord::DeleteRestrictionError => e
      @parent.errors.add(:base, e)
      flash[:error] = "#{e}"
    ensure
      respond_to do |format|
        format.html { redirect_to parents_url}
        format.json { head :no_content }
      end
    end
  end

  def upload_photo
    @parent = Parent.where(id: params[:id]).update( upload_photo_params )
  end

  def get_autocomplete
    @parents = Parent.search_by_name_and_mobile(params[:search])
    render json: @parents.order(:id).limit(10).as_json({ autocomplete: true }), status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_parent
      @parent = Parent.includes([:students, :relationships]).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def parent_params
      params.require(:parent).permit(:full_name, :nickname, :id_card_no, :mobile, :email, :line_id, :img_url )
    end

    def relation_assign
      @parent.students.clear
      @parent.students << @students
      @students.each_with_index do |student, index|
        std_parent = StudentsParent.find_by_student_id_and_parent_id(student.id, @parent.id)
        std_parent.relationship_id = @relationships[index]
        std_parent.save
      end
    end

    def student_assign
      std_params = params[:student]
      rel_params = params[:relationship]

      std_rel = Hash.new
      if !std_params.nil? && !rel_params.nil?
        std_params.each_with_index { |value, index| std_rel[value] = rel_params[index] }
      end
      std_params = std_rel.keys
      @relationships = std_rel.values

      @students = Array.new
      if !std_params.nil?
        std_params.each_with_index.map do |s, index|
          if s.to_i != 0
            begin
              std = Student.find(s)
            rescue
              std = Student.find_or_create_by(full_name: s)
            end
            @students.push(std)
          elsif s.length > 0 && s.to_i == 0
            new_std = Student.find_or_create_by(full_name: std_params[index])
            @students.push(new_std)
          end
        end
      end
    end

    def upload_photo_params
      params.require(:parent).permit(:img_url)
    end

    def get_parents(class_select, grade_select, search, page, per_page, sort, order)
      if grade_select.downcase == 'all' && class_select.downcase != 'all'
        classroom = Classroom.where(name: class_select).first
        qry_filter = "and classrooms.id = #{classroom.id}"
        qry_filter2 = "classrooms.id = #{classroom.id} and"
      elsif grade_select.downcase != 'all' && class_select.downcase == 'all'
        grade = Grade.where(name: grade_select).first
        qry_filter = "and grades.id = #{grade.id}"
        qry_filter2 = "grades.id = #{grade.id} and"
      elsif grade_select.downcase != 'all' && class_select.downcase != 'all'
        grade = Grade.where(name: grade_select).first
        classroom = Classroom.where(name: class_select).first
        qry_filter = "and (grades.id = #{grade.id} AND classrooms.id = #{classroom.id})"
        qry_filter2 = "(grades.id = #{grade.id} AND classrooms.id = #{classroom.id}) and"
      end

      where_sql = " where parents.deleted_at IS NULL AND ( #{qry_filter2} (parents.full_name LIKE '%#{search}%' OR parents.full_name_english LIKE '%#{search}%' OR parents.email LIKE '%#{search}%' OR parents.mobile LIKE '%#{search}%' OR students.full_name LIKE '%#{search}%' OR students.full_name_english LIKE '%#{search}%') )"
      order_sql = sort || order ? " order by #{sort || ''} #{order || ''}" : ""
      arr_parents = Parent.find_by_sql("select parents.id, parents.full_name ,parents.mobile,parents.email,relationships.name, students.full_name as student_name, students.id as student_id from parents left outer join students_parents on students_parents.id IN ( select students_parents.id from students_parents left join students on students_parents.student_id = students.id left join grades on students.grade_id = grades.id left join classrooms on students.classroom_id = classrooms.id where students_parents.parent_id = parents.id #{qry_filter} limit 1) left join students on students_parents.student_id = students.id left join relationships on relationships.id=students_parents.relationship_id left join grades on students.grade_id = grades.id left join classrooms on students.classroom_id = classrooms.id" + where_sql + order_sql).paginate(page: page, per_page: per_page)

      return arr_parents
    end

  end
