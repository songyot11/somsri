class VacationLeaveRulesController < ApplicationController
  load_and_authorize_resource except: [:index]

  def index
    render json: VacationLeaveRule.first_or_create
  end

  def update
    vacation_leave_rule = VacationLeaveRule.first
    vacation_leave_rule.message = params[:message]
    vacation_leave_rule.updated_by = current_user
    if vacation_leave_rule.save
      render json: vacation_leave_rule, status: :ok
    else
      render json: vacation_leave_rule.errors, status: 500
    end
  end
end
