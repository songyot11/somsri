class RollCallsController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:create]
  before_action :authenticate_user!, unless: :is_api?

  def is_api?
    !params[:pin].blank?
  end

  # OUTPUT:
  # {
    # data:[
    #   {
    #     date: 1/20/222,
    #     class: 1/1,
    #     morning: [student1, student2]
    #     afternoon: [student1, student2]
    #   }
    # ]
  # }
  #
  # student_ex = {
  #   student_id: “1”
  #   first_name: "",
  #   last_name: "",
  #   prefix: "",
  #   status: ""
  #   image_url:””
  # }

  # INPUT: {
  #   token: "",
  #   date_check_line: date(STRING),
  #   class: "",
  #   morning: [{student_code, status}, ...],
  #   afternoon: [{student_code, status}, ...]
  # }
  # POST /roll_calls/
  def create
    user = get_current_user(params[:pin])
    if user
      # get data
      render json: { errors: "class is required params" }, status: 422 and return if !params[:class]
      list_name = params[:class]
      render json: { errors: "date_check_line is required params" }, status: 422 and return if !params[:date_check_line]
      date = params[:date_check_line]

      render json: { errors: "morning is required params" }, status: 422 and return if !params[:morning]
      render json: { errors: "morning isn't JSON" }, status: 422 and return if !is_json(params[:morning])
      morning = add_round_property(JSON.parse(params[:morning]), "morning")

      render json: { errors: "afternoon is required params" }, status: 422 and return if !params[:afternoon]
      render json: { errors: "afternoon isn't JSON" }, status: 422 and return if !is_json(params[:afternoon])
      afternoon = add_round_property(JSON.parse(params[:afternoon]), "afternoon")
      datas = (morning << afternoon).flatten

      # craete roll call
      not_found_code = nil
      roll_calls = []
      RollCall.transaction do
        # get target class
        list = List.where({ name: list_name, user_id: user.id }).first
        render json: { errors: "class not found" }, status: 422 and return if !list

        # get students
        student_codes = datas.collect { |data| data['student_code'] }
        students = Student.where({ code: student_codes }).to_a

        # prepare roll call datas
        roll_call_datas = []
        students.each do |student|
          datas.each do |data|
            if student.student_number.to_s == data['student_code'].to_s
              roll_call_datas << RollCall.new({
                student_id: student.id,
                status: data['status'],
                round: data["round"],
                list_id: list.id,
                check_date: date
              })
            end
          end
        end

        # create roll call
        conflict_target = [:student_id, :round, :list_id, :check_date]
        result_ids = RollCall.import(roll_call_datas, on_duplicate_key_update: {conflict_target: conflict_target, columns: [:status]})[:ids]
      end
      render json: RollCall.get_by_date(user, date, format_api: true).to_json(format_api: true) and return
    else
      render json: { errors: "Invalid token or user not registered" }, status: 422 and return
    end
  end

  def index
    date = params[:date]
    user = get_current_user(params[:pin])
    if user
      if date
        render json: RollCall.get_by_date(user, date, format_api: true).to_json(format_api: true)
      else
        list_ids = user.lists.collect{ |l| l.id }
        render json: RollCall.where({ list_id: list_ids })
      end
    else
      render json: { errors: "Invalid token or user not registered" }, status: 422 and return
    end
  end


  def report
    date = params[:date]
    user = get_current_user(params[:pin])
    if user
      if date
        render json: RollCall.get_by_permision(user, date, format_api: true).to_json(format_api: true)
      else
        list_ids = user.lists.collect{ |l| l.id }
        render json: RollCall.where({ list_id: list_ids })
      end
    else
      render json: { errors: "Invalid token or user not registered" }, status: 422 and return
    end
  end

  def report_month
    date = params[:date]
    user = get_current_user(params[:pin])
    if user
      if date
        render json: RollCall.get_by_month(user, date, format_api: true).to_json(format_api: true)
      else
        render json: { errors: "Date is required in report_month." }, status: 422 and return
      end
    else
      render json: { errors: "Invalid token or user not registered" }, status: 422 and return
    end
  end

  private
  def add_round_property(datas, round)
    datas.each do |d|
      d["round"] = round
    end
    return datas
  end

end
