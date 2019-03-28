class VacationConfigsController < ApplicationController
  load_and_authorize_resource

  def index
    vacation_setting = VacationSetting.where(school_id: current_user.employee.school_id).first
    leaves = current_user.employee.vacations.this_year

    max_leave = (!current_user.employee.sick_leave_maximum_days_per_year.nil?) ? current_user.employee.sick_leave_maximum_days_per_year : 0
    max_leave += (!current_user.employee.personal_leave_maximum_days_per_year.nil?) ? current_user.employee.personal_leave_maximum_days_per_year : 0
    
    render json: vacation_setting.attributes.merge(
      leave_remaining: max_leave - leaves.count,
      personal_leave_remaining: current_user.employee.personal_leave_remaining,
      sick_leave_remaining: current_user.employee.sick_leave_remaining,
      switch_day_remaining: current_user.employee.switch_day_remaining,
      work_at_home_remaining: current_user.employee.work_at_home_remaining,
      switching_day_allow: (!current_user.employee.switching_day_allow.nil?) ? current_user.employee.switching_day_allow : vacation_setting.switching_day_allow,
      work_at_home_allow: (!current_user.employee.work_at_home_allow.nil?)  ? current_user.employee.work_at_home_allow : vacation_setting.work_at_home_allow
    ), status: :ok
  end
end
