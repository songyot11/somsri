class ScoutsController < ApplicationController
  def index
    @candidate = Candidate.find_by(id: 1)
    render json: @candidate, status: :ok
    
  end

end