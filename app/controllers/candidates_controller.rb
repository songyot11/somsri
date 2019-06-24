class CandidatesController < ApplicationController

  def index
    @candidate = Candidate.all
    total = @candidate.size
    @candidate = @candidate.offset(params[:offset]).limit(params[:limit])
    
    render json: {
      rows: @candidate.as_json,
      total: total
    }, status: :ok
  end
  
  def destroy
    @candidate = Candidate.find_by(id: params[:id])
    @candidate.destroy
  end

end