class VacationsController < ApplicationController
  load_and_authorize_resource

  def index
    year = Time.current.year
    start_date = Date.new(year, 1, 1).beginning_of_day
    end_date = Date.new(year, 12, 31).end_of_day
    @vacations = @vacations.where('created_at BETWEEN ? AND ?', start_date, end_date)

    sick_leave = @vacations.where(vacation_type: VacationType.where(name: 'ลาป่วย').first.id).count
    vacation_leave = @vacations.where(vacation_type: VacationType.where(name: 'ลากิจ').first.id).count
    switch_date = @vacations.where(vacation_type: VacationType.where(name: 'สลับวันทำงาน').first.id).count
    work_at_home = @vacations.where(vacation_type: VacationType.where(name: 'ทำงานที่บ้าน').first.id).count
    remaining_day = current_user.leave_allowance - vacation_leave

    render json: {
      leave_allowance: current_user.leave_allowance,
      remaining_day: remaining_day,
      sick_leave: sick_leave,
      vacation_leave: vacation_leave,
      switch_date: switch_date,
      work_at_home: work_at_home,
      vacations: @vacations
    }, status: :ok
  end
end
