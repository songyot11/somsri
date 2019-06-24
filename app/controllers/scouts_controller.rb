class ScoutsController < ApplicationController
  
  def edit
    render json: getInfo(params[:id]), status: :ok
  end
  
  def update_candidate
    @candidate = Candidate.find_by(id: params[:id])
    @candidate.update(params_candidate)
    @programming_skill = ProgrammingSkill.find_by(id: params[:id])
    @programming_skill.update(params_programming_skill)
  end


  private

  def getInfo(id)
    {
      candidate: Candidate.find_by(id: id),
      programming_skill: ProgrammingSkill.find_by(id: id) 
    }
  end

  def params_candidate
    params.require(:candidate).permit(:full_name, :nick_name, :email)
  end

  def params_programming_skill
    params.require(:programming_skill).permit(:skill_name, :skill_point)
  end

  
end