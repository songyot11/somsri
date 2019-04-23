class EmployeeSkillsController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:update, :create, :destroy]

  def index
    employee = Employee.with_deleted.find(params[:employee_id])
    render json: employee.employee_skills.joins(:skill).order('skills.name asc')
  end

  def create
    employee = Employee.with_deleted.find(params[:employee_id])
    @employee_skill = employee.employee_skills.new(employee_skill_params)
    if @employee_skill.save
      render json: @employee_skill, status: :ok
    else
      render json: @employee_skill.errors, status: 500
    end
  end

  def update
    employee = Employee.with_deleted.find(params[:employee_id])
    @employee_skill = employee.employee_skills.find(params[:id])
    if @employee_skill.update(params_employee_skill)
      render json: @employee_skill, status: :ok
    else
      render json: @employee_skill.errors, status: 500
    end
  end

  def destroy
    employee = Employee.with_deleted.find(params[:employee_id])
    @employee_skill = employee.employee_skills.find(params[:id])
    @employee_skill.destroy
    render json: {status: 'success' }, status: :ok
  end

  private
  def employee_skill_params
    params.require(:employee_skill).permit(:skill_id, :score)
  end
end
