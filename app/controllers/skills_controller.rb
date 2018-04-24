class SkillsController < ApplicationController
  def index
    skill = Skill.order(name: :asc)
    render json: skill, status: :ok
  end

  def create
    skill = Skill.new(params_skill)
    if skill.save
      render json: skill, statu: :ok
    end
  end

  private
  def params_skill
    params.require(:skill).permit(:name)
  end
end
