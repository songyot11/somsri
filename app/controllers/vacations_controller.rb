class VacationsController < ApplicationController
  load_and_authorize_resource

  def index
    render json: Vacation.all.this_year, status: :ok
  end

  def create
    send_approve_mail = true
    vacation = Vacation.new(vacation_params)
    vacation.requester = current_user.employee
    vacation.vacation_type = get_vacation_type(params[:vacation_type])

    vacation_setting = VacationSetting.where(school_id: current_user.employee.school_id).first
    # Check require approve
    case vacation.vacation_type.name
    when 'ลาป่วย'
      if !vacation_setting.nil? and !vacation_setting.sick_leave_require_approval
        vacation.status = 'approved'
        vacation.approver = current_user.employee
        send_approve_mail = false
      end
    when 'สลับวันทำงาน'
      if !vacation_setting.nil? and !vacation_setting.switching_day_require_approval
        vacation.status = 'approved'
        vacation.approver = current_user.employee
        send_approve_mail = false
      end
    when 'ทำงานที่บ้าน'
      if !vacation_setting.nil? and !vacation_setting.work_at_home_require_approval
        vacation.status = 'approved'
        vacation.approver = current_user.employee
        send_approve_mail = false
      end
    end

    if vacation.save
      if send_approve_mail
        send_vacation_request(vacation)
      end
      render json: vacation, status: :ok
    else
      render json: { error_message: vacation.errors }, status: 500
    end
  end

  def destroy
    vacation = Vacation.find(params[:id])
    if vacation.destroy
      render json: { status: 'success' }, status: :ok
    else
      render json: { error_message: vacation.errors }, status: 500
    end
  end

  def dashboard

    is_me = params["me"].present?

    if is_me && (current_user.admin? || current_user.human_resource?)
      @vacations = @vacations.where(requester_id: current_user.id)
    end

    @vacations = @vacations.this_year.order('created_at DESC')

    sick_leave_count = @vacations.sick_leave.count
    full_day_leave_count = @vacations.vacation_full_day.not_rejected.count
    half_day_morning_leave_count = @vacations.vacation_half_day_morning.not_rejected.count
    half_day_afternoon_leave_count = @vacations.vacation_half_day_afternoon.not_rejected.count
    vacation_leave_count = full_day_leave_count + half_day_morning_leave_count + half_day_afternoon_leave_count
    switch_date_count = @vacations.switch_date.count
    work_at_home_count = @vacations.work_at_home.count

    render json: {
      maximum_leave: current_user.employee.maximum_leave,
      remaining_day: current_user.employee.leave_remaining,
      sick_leave: sick_leave_count,
      vacation_leave: vacation_leave_count,
      switch_date: switch_date_count,
      work_at_home: work_at_home_count,
      vacations: @vacations
    }, status: :ok
  end

  def approve
    vacation = Vacation.find(params[:id])
    authorize! :approve, vacation

    if vacation.pending?
      vacation.status = 'approved'
      vacation.approver = current_user.employee
      if vacation.save
        VacationMailer.approved_rejected(vacation)
        # redirect_to '/somsri#/vacation/dashboard/approved'
      else
        # redirect_to '/somsri#/vacation/dashboard/error'
      end
    else
      # redirect_to '/somsri#/vacation/dashboard/'
    end
  end

  def reject
    vacation = Vacation.find(params[:id])
    authorize! :reject, vacation

    if vacation.pending?
      vacation.status = 'rejected'
      vacation.approver = current_user.employee
      if vacation.save
        VacationMailer.approved_rejected(vacation)
        # redirect_to '/somsri#/vacation/dashboard/rejected'
      else
        # redirect_to '/somsri#/vacation/dashboard/error'
      end
    else
      # redirect_to '/somsri#/vacation/dashboard/'
    end
  end

  private

  def vacation_params
    params.permit(:start_date, :end_date, :detail)
  end

  def get_vacation_type(vacation_type)
    case vacation_type
    when 'sick_leave'
      VacationType.where(name: 'ลาป่วย').first
    when 'vacation_leave_full_day'
      VacationType.where(name: 'ลากิจ').first
    when 'vacation_leave_half_day_morning'
      VacationType.where(name: 'ลากิจครึ่งวันเช้า').first
    when 'vacation_leave_half_day_afternoon'
      VacationType.where(name: 'ลากิจครึ่งวันบ่าย').first
    when 'switch_date'
      VacationType.where(name: 'สลับวันทำงาน').first
    when 'work_at_home'
      VacationType.where(name: 'ทำงานที่บ้าน').first
    end
  end

  def send_vacation_request(vacation)
    case vacation.vacation_type.name
    when 'ลาป่วย'
      VacationMailer.sick_leave_request(current_user.employee, vacation)
    when 'ลากิจ', 'ลากิจครึ่งวันเช้า', 'ลากิจครึ่งวันบ่าย'
      VacationMailer.vacation_leave_request(current_user.employee, vacation)
    when 'สลับวันทำงาน'
      VacationMailer.switch_date_request(current_user.employee, vacation)
    when 'ทำงานที่บ้าน'
      VacationMailer.work_at_home_request(current_user.employee, vacation)
    end
  end
end
