class InterviewsController < ApplicationController

  def create
    ap interview_params[:date]
    if interview_params[:id].present?
      interview = Interview.find(interview_params[:id])
      interview.update(interview_params)
    else
      Interview.create(interview_params)
    end 
  end

  private

  def interview_params
    params.require(:interview).permit(:id, :email, :date, :location, :candidate_id)
  end
end