class ReportRollCallsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource :class => :report_roll_call

  def report
    dates = date_exclude_weeken(DateTime.parse(params[:date]))
    dates.collect! do |date|
      [date.strftime("%Y-%m-%d"), date.strftime("%d")]
    end
    list = List.first
    if params[:list_id]
      list = List.where(id: params[:list_id]).first
    end

    results = []
    if list
      roll_calls = RollCall.where(check_date: dates.collect{ |d| d[0] }, list_id: list.id).to_a
      student_ids = roll_calls.collect{ |rc| rc.student_id }.uniq
      students = Student.with_deleted.where(id: student_ids).order(:classroom_number).to_a

      students.each do |student|
        result = { classroom_number: student.classroom_number, name: student.full_name_with_title, roll_calls: [] }
        dates.each do |date|
          result[:roll_calls] << {
            date: date[1],
            morning: getRollCallStatus(roll_calls, "morning", date[0], student.id),
            afternoon: getRollCallStatus(roll_calls, "afternoon", date[0], student.id)
          }
        end
        results << result
      end
    end
    school = School.first
    render json: { info: { name: school.name, address: school.address }, rollcall: results }
  end

  def date_in_month
    dates = date_exclude_weeken(DateTime.parse(params[:date]))
    dates.collect! do |date|
      date.strftime("%d").to_i.to_s
    end
    render json: dates
  end

  def lists
    render json: List.all
  end

  def months
    check_dates = RollCall.distinct.pluck(:check_date).to_a
    results = check_dates.collect do |x|
      date_thai = to_thai_date(DateTime.parse(x))
      {name: "#{date_thai[1]} #{date_thai[2]}", date: DateTime.parse(x).strftime("%Y-%m-%d")}
    end
    results.uniq! do |x|
      DateTime.parse(x[:date]).strftime("%m %Y")
    end
    render json: results
  end

  protected
  def date_exclude_weeken(date)
    only_weekdays(date.beginning_of_month..date.end_of_month)
  end

  def only_weekdays(range)
    range.select { |d| (1..5).include?(d.wday) }
  end

  def getRollCallStatus(roll_calls, round, date, student_id)
    roll_calls.each do |roll_call|
      if roll_call.student_id == student_id && roll_call.round == round && roll_call.check_date == date
        return roll_call.status
      end
    end
    return nil
  end

  def to_thai_date(date_time)
    d = I18n.l(date_time, format: "%d %B %Y").split(" ")
    return [ d[0].to_i, d[1], d[2].to_i + 543 ]
  end

end
