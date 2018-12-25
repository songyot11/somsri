class HolidaysController < ApplicationController

  def index
    render json: Holiday.all, status: :ok
  end

  def create
    holiday = Holiday.new(name: params[:name],
      start_at: params[:start_at].to_datetime,
      end_at: params[:end_at].to_datetime,
    )
    if holiday.save
      render json: holiday, status: :ok
    else
      render json: { error_message: holiday.errors }, status: 500
    end
  end

  def destroy
    holiday = Holiday.find(params[:id])
    if holiday.destroy
      render json: { status: 'success' }, status: :ok
    else
      render json: { error_message: holiday.errors }, status: 500
    end
  end

  private

  def holiday_params
    params.permit(:name, :start_at, :end_at)
  end
end
