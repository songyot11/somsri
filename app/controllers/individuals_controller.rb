class IndividualsController < ApplicationController
  load_and_authorize_resource except: [:create]
  skip_before_action :verify_authenticity_token, :only => [:update, :create, :destroy]

  # GET /individuals/
  def index
    render plain: "Employee not found", status: 404 and return if params[:employee_id].blank?
    if params[:employee_id]=="0"
      employee = Employee.new
    else
      employee = Employee.where(id: params[:employee_id], school_id: current_user.school.id).first
    end
    if employee
      render json: {
        emergency_calls: employee.emergency_calls,
        spouses: employee.spouses,
        childs: employee.childs,
        parents: employee.parents,
        friends: employee.friends
      }.as_json({ full_name: true })
    else
      render plain: "Employee not found", status: 500
    end
  end

  # POST /individuals/
  def create
    individual = Individual.new individual_params
    if individual.save
      individual.reload
      render json: individual.as_json({ full_name: true }), status: :ok
    else
      render json: individual.errors, status: 500
    end
  end

  # PATCH /individuals/:id
  def update
    if @individual.update(individual_params)
      @individual.reload
      render json: @individual.as_json({ full_name: true }), status: :ok
    else
      render json: @individual.errors, status: 500
    end
  end

  # DELETE /individuals/:id
  def destroy
    @individual.destroy
    render plain: "Deleted", status: :ok
  end

  private
  def individual_params
    params.require(:individual).permit([
      :relationship,
      :prefix_thai,
      :first_name_thai,
      :last_name_thai,
      :prefix,
      :first_name,
      :middle_name,
      :last_name,
      :personal_id,
      :passport_number,
      :race,
      :nationality,
      :phone,
      :email,
      :emergency_call_id,
      :spouse_id,
      :child_id,
      :parent_id,
    ]).to_h
  end

end
