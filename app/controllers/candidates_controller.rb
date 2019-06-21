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

  def show
    ap 'show >>>>>>>>>'
  end  
end