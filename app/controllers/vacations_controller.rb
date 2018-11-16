class VacationsController < ApplicationController
  load_and_authorize_resource

  def index
    year = Time.current.year
    start_date = Date.new(year, 1, 1).beginning_of_day
    end_date = Date.new(year, 12, 31).end_of_day
    @vacations = @vacations.where('created_at BETWEEN ? AND ?', start_date, end_date).order('created_at DESC')

    sick_leave_count = @vacations.sick_leave.count
    full_day_leave = @vacations.vacation_full_day
    half_day_morning_leave = @vacations.vacation_half_day_morning
    half_day_afternoon_leave = @vacations.vacation_half_day_afternoon
    vacation_leave_count = full_day_leave.not_approved.count + half_day_morning_leave.not_approved.count + half_day_afternoon_leave.not_approved.count
    switch_date_count = @vacations.switch_date.count
    work_at_home_count = @vacations.work_at_home.count

    deduce_days = 0
    deduce_days += sick_leave_count * VacationType.sick_leave.deduce_days
    deduce_days += full_day_leave.not_approved.count * VacationType.vacation_full_day.deduce_days
    deduce_days += half_day_morning_leave.not_approved.count * VacationType.vacation_half_day_morning.deduce_days
    deduce_days += half_day_afternoon_leave.not_approved.count * VacationType.vacation_half_day_afternoon.deduce_days
    deduce_days += switch_date_count * VacationType.switch_date.deduce_days
    type_work_at_home = VacationType.work_at_home
    deduce_days += work_at_home_count * type_work_at_home.deduce_days
    remaining_day = current_user.leave_allowance - deduce_days

    render json: {
      leave_allowance: current_user.leave_allowance,
      remaining_day: remaining_day,
      sick_leave: sick_leave_count,
      vacation_leave: vacation_leave_count,
      switch_date: switch_date_count,
      work_at_home: work_at_home_count,
      vacations: @vacations
    }, status: :ok
  end

  def create
    vacation = Vacation.new(vacation_params)
    vacation.vacation_type_id = get_vacation_type_id(params[:vacation_type])
    if vacation.save
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
end
