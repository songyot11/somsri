class VacationsController < ApplicationController
  load_and_authorize_resource

  def index
    year = Time.current.year
    start_date = Date.new(year, 1, 1).beginning_of_day
    end_date = Date.new(year, 12, 31).end_of_day
    @vacations = @vacations.where('created_at BETWEEN ? AND ?', start_date, end_date)

    type_sick_leave = VacationType.where(name: 'ลาป่วย').first
    type_full_day_leave = VacationType.where(name: 'ลากิจ').first
    type_half_day_morning_leave = VacationType.where(name: 'ลากิจครึ่งวันเช้า').first
    type_half_day_afternoon_leave = VacationType.where(name: 'ลากิจครึ่งวันบ่าย').first
    type_swtich_date = VacationType.where(name: 'สลับวันทำงาน').first
    type_work_at_home = VacationType.where(name: 'ทำงานที่บ้าน').first

    sick_leave_count = @vacations.where(vacation_type: type_sick_leave.id).count
    full_day_leave_count = @vacations.where(vacation_type: type_full_day_leave.id).count
    half_day_morning_leave_count = @vacations.where(vacation_type: type_half_day_morning_leave.id).count
    half_day_afternoon_leave_count = @vacations.where(vacation_type: type_half_day_afternoon_leave.id).count
    vacation_leave = full_day_leave_count + half_day_morning_leave_count + half_day_afternoon_leave_count
    switch_date_count = @vacations.where(vacation_type: type_swtich_date.id).count
    work_at_home_count = @vacations.where(vacation_type: type_work_at_home.id).count

    deduce_days = 0
    deduce_days += sick_leave_count * type_sick_leave.deduce_days
    deduce_days += full_day_leave_count * type_full_day_leave.deduce_days
    deduce_days += half_day_morning_leave_count * type_half_day_morning_leave.deduce_days
    deduce_days += half_day_afternoon_leave_count * type_half_day_afternoon_leave.deduce_days
    deduce_days += switch_date_count * type_swtich_date.deduce_days
    deduce_days += work_at_home_count * type_work_at_home.deduce_days
    remaining_day = current_user.leave_allowance - deduce_days

    render json: {
      leave_allowance: current_user.leave_allowance,
      remaining_day: remaining_day,
      sick_leave: sick_leave_count,
      vacation_leave: vacation_leave,
      switch_date: switch_date_count,
      work_at_home: work_at_home_count,
      vacations: @vacations
    }, status: :ok
  end
end
