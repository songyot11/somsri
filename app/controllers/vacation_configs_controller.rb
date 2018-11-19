class VacationConfigsController < ApplicationController
  load_and_authorize_resource

  def index
    vacation_config = @vacation_configs.first
    leaves = current_user.vacations.where('created_at BETWEEN ? AND ?', Date.today.at_beginning_of_year, Date.today.at_end_of_year)
    work_at_homes = current_user.vacations.where(vacation_type: VacationType.where(name: 'ทำงานที่บ้าน').first.id)

    if vacation_config.work_at_home_unit == "week"
      work_at_homes = work_at_homes.where('created_at BETWEEN ? AND ?', Date.today.at_beginning_of_week, Date.today.at_end_of_week)
    elsif vacation_config.work_at_home_unit == "month"
      work_at_homes = work_at_homes.where('created_at BETWEEN ? AND ?', Date.today.at_beginning_of_month, Date.today.at_end_of_month)
    end

    render json: vacation_config.attributes.merge(
      leave_remaining: current_user.leave_allowance - leaves.count,
      work_at_home_remaining: vacation_config.work_at_home_limit - work_at_homes.count
    ), status: :ok
  end
end
