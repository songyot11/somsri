class InterviewsController < ApplicationController

  def create
    if interview_params[:id].present?
      interview = Interview.find(interview_params[:id])
      interview.update(interview_params)
      InterviewMailer.edit_interview_notification(interview).deliver
    else
      interview = Interview.create(interview_params)
      InterviewMailer.interview_notification(interview).deliver      
    end 
  end

  private

  def interview_params
    params.require(:interview).permit(:id, :email, :date, :location, :candidate_id)
  end
end