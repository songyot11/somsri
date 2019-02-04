class EmployeeSkillsController < ApplicationController
  load_and_authorize_resource :employee
  load_and_authorize_resource :employee_skill, through: :employee
  skip_before_action :verify_authenticity_token, :only => [:update, :create, :destroy]

  def index
    render json: @employee.employee_skills.joins(:skill).order('skills.name asc')
  end

  def create
    p @employee_skill
    if @employee_skill.save
      render json: @employee_skill, status: :ok
    else
      render json: @employee_skill.errors, status: 500
    end
  end

  def update
    if @employee_skill.update(params_employee_skill)
      render json: @employee_skill, status: :ok
    else
      render json: @employee_skill.errors, status: 500
    end
  end

  def destroy
    @employee_skill.destroy
    render json: {status: 'success' }, status: :ok
  end

  private
  def employee_skill_params
    params.require(:employee_skill).permit(:skill_id, :score)
  end
end
