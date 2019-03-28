class VacationSettingsController < ApplicationController
  load_and_authorize_resource except: [:index]

  def index
    vacationsetting =  VacationSetting.where(school_id: current_user.school_id).first
    if vacationsetting.nil?
      render json:VacationSetting.new(), status: :ok
    else
      render json:vacationsetting, status: :ok
    end
  end

  def create
    vacationsetting = VacationSetting.new(vacation_setting_params)
    vacationsetting.school_id = current_user.school_id
    if vacationsetting.save
      render json: vacationsetting, status: :ok
    else
      render json: { error_message: vacationsetting.errors }, status: 500
    end
  end

  def update
    vacationsetting = VacationSetting.find(params[:id])
    if vacationsetting.update(vacation_setting_params)
      render json: vacationsetting, status: :ok
    else
      render json: { error_message: vacationsetting.errors }, status: 500
    end
  end

  private
  def vacation_setting_params
    result = params.permit([
      :sick_leave_maximum_days_per_year,
      :sick_leave_require_approval,
      :sick_leave_require_medical_certificate,
      :sick_leave_note,
      :personal_leave_maximum_days_per_year,
      :personal_leave_submission_days,
      :personal_leave_allow_morning,
      :personal_leave_allow_afternoon,
      :personal_leave_note,
      :switching_day_allow,
      :switching_day_maximum_days_per_year,
      :switching_day_require_approval,
      :switching_day_submission_days,
      :switching_day_note,
      :work_at_home_allow,
      :work_at_home_maximum_days_per_week,
      :work_at_home_require_approval,
      :work_at_home_submission_days,
      :work_at_home_note
    ]).to_h
    return result
  end

end
