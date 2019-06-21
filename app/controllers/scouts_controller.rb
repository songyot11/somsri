class ScoutsController < ApplicationController
  def index
    @candidate = Candidate.find_by(id: 1)
    render json: @candidate, status: :ok
  end
  
  def update_candidate
    @candidate = Candidate.find_by(id: params[:id])
    @candidate.update(params_candidate)
  end



  private


  def params_candidate
    params.require(:candidate).permit(:full_name, :nick_name, :email)
  end

  
end