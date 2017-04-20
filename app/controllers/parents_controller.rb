class ParentsController < ApplicationController
  before_action :set_parent, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  load_and_authorize_resource
  # GET /parents
  # GET /parents.json
  def index
    students = Student.all.order("classroom ASC")
    class_select = (params[:class_select] || 'All')
    @classroom_display = []
    students.each do |student|
      if !@classroom_display.include?(student.classroom)
        @classroom_display.push(student.classroom)
      end
    end
    if class_select.downcase == 'all'
      @parents = Parent.with_deleted.page(params[:page]).search(params[:search]).order("deleted_at DESC , full_name ASC").includes(:students, :relationships, :invoices)
    else
      parent_joins = Parent.joins(:students).where(students:{classroom: class_select})
      @parents = parent_joins.with_deleted.search(params[:search]).page(params[:page]).order("parents.deleted_at DESC , parents.full_name ASC").includes(:students, :relationships, :invoices)
    end
      @filter_grade = class_select
      @menu = "ผู้ปกครอง"
      render "parents/index", layout: "application_invoice"
  end

  # GET /parents/1
  # GET /parents/1.json
  def show
    @menu = "ผู้ปกครอง"
    render "parents/show", layout: "application_invoice"
  end

  # GET /parents/new
  def new
    @menu = "ผู้ปกครอง"
    @parent = Parent.new
    @students = Student.all
    @relations = Relationship.all

    render "parents/new", layout: "application_invoice"
  end

  # GET /parents/1/edit
  def edit
    @menu = "ผู้ปกครอง"
    @students = Student.all
    @relations = Relationship.all

    render "parents/edit", layout: "application_invoice"
  end

  # POST /parents
  # POST /parents.json
  def create
    @parent = Parent.new(parent_params)
    student_assign
    respond_to do |format|
      if @parent.save
        relation_assign
        format.html { redirect_to @parent}
        format.json { render :show, status: :created, location: @parent }
      else
        format.html { render :new }
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
        format.html { redirect_to @parent}
        format.json { render :show, status: :ok, location: @parent }
      else
        format.html { render :edit }
        format.json { render json: @parent.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parents/1
  # DELETE /parents/1.json
  def destroy
    @parent.destroy
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
    Parent.restore(params[:parent_id])
    respond_to do |format|
      format.html { redirect_to parents_url}
      format.json { head :no_content }
    end
  end

  def real_destroy
    begin
      @parent = Parent.find(params[:parent_id])
      @parent.really_destroy!
      flash[:success] = "ลบผู้ปกครองเรียบร้อยแล้ว"
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
      if !std_params.nil?
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

end
