class VacationsController < ApplicationController
  load_and_authorize_resource

  def index
    @vacations = @vacations.this_year.order('created_at DESC')

    sick_leave_count = @vacations.sick_leave.count
    full_day_leave_count = @vacations.vacation_full_day.not_rejected.count
    half_day_morning_leave_count = @vacations.vacation_half_day_morning.not_rejected.count
    half_day_afternoon_leave_count = @vacations.vacation_half_day_afternoon.not_rejected.count
    vacation_leave_count = full_day_leave_count + half_day_morning_leave_count + half_day_afternoon_leave_count
    switch_date_count = @vacations.switch_date.count
    work_at_home_count = @vacations.work_at_home.count

    render json: {
      leave_allowance: current_user.leave_allowance,
      remaining_day: current_user.leave_remaining,
      sick_leave: sick_leave_count,
      vacation_leave: vacation_leave_count,
      switch_date: switch_date_count,
      work_at_home: work_at_home_count,
      vacations: @vacations
    }, status: :ok
  end

  def create
    vacation = Vacation.new(vacation_params)
    vacation.user = current_user
    vacation.vacation_type_id = get_vacation_type_id(params[:vacation_type])
    if vacation.save
      send_vacation_request(vacation)
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

  def approve
    vacation = Vacation.find(params[:id])
    authorize! :approve, vacation

    if vacation.pending?
      vacation.status = 'approved'
      vacation.approver = current_user
      if vacation.save
        VacationMailer.approved_rejected(vacation)
        redirect_to '/somsri#/vacation/dashboard/approved'
      else
        redirect_to '/somsri#/vacation/dashboard/error'
      end
    else
      redirect_to '/somsri#/vacation/dashboard/'
    end
  end

  def reject
    vacation = Vacation.find(params[:id])
    authorize! :reject, vacation

    if vacation.pending?
      vacation.status = 'rejected'
      vacation.approver = current_user
      if vacation.save
        VacationMailer.approved_rejected(vacation)
        redirect_to '/somsri#/vacation/dashboard/rejected'
      else
        redirect_to '/somsri#/vacation/dashboard/error'
      end
    else
      redirect_to '/somsri#/vacation/dashboard/'
    end
  end

  private

  def vacation_params
    params.permit(:start_date, :end_date, :detail)
  end

  def get_vacation_type_id(vacation_type)
    case vacation_type
    when 'sick_leave'
      VacationType.where(name: 'ลาป่วย').first.id
    when 'vacation_leave_full_day'
      VacationType.where(name: 'ลากิจ').first.id
    when 'vacation_leave_half_day_morning'
      VacationType.where(name: 'ลากิจครึ่งวันเช้า').first.id
    when 'vacation_leave_half_day_afternoon'
      VacationType.where(name: 'ลากิจครึ่งวันบ่าย').first.id
    when 'switch_date'
      VacationType.where(name: 'สลับวันทำงาน').first.id
    when 'work_at_home'
      VacationType.where(name: 'ทำงานที่บ้าน').first.id
    end
  end

  def send_vacation_request(vacation)
    case vacation.vacation_type.name
    when 'ลาป่วย'
      VacationMailer.sick_leave_request(current_user, vacation)
    when 'ลากิจ', 'ลากิจครึ่งวันเช้า', 'ลากิจครึ่งวันบ่าย'
      VacationMailer.vacation_leave_request(current_user, vacation)
    when 'สลับวันทำงาน'
      VacationMailer.switch_date_request(current_user, vacation)
    when 'ทำงานที่บ้าน'
      VacationMailer.work_at_home_request(current_user, vacation)
    end
  end
end
