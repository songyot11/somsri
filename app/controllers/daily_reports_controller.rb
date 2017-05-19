class DailyReportsController < ApplicationController
  before_action :set_daily_report, only: [:show]
  skip_before_action :verify_authenticity_token, :only => [:create]
  load_and_authorize_resource

  # GET /daily_reports
  def show
    school = School.first
    render json: {
      logo: school.logo.url(:medium),
      school: school,
      cash: @daily_report.cash,
      credit_card: @daily_report.credit_card,
      cheque: @daily_report.cheque,
      tranfers: @daily_report.tranfers,
      total: @daily_report.total,
      real_start_cash: @daily_report.real_start_cash,
      real_cash: @daily_report.real_cash,
      real_credit_card: @daily_report.real_credit_card,
      real_cheque: @daily_report.real_cheque,
      real_tranfers: @daily_report.real_tranfers,
      real_total: @daily_report.real_total,
      thai_now_date: I18n.l(@daily_report.created_at, format: "%d %B #{@daily_report.created_at.year + 543}"),
      now_time: @daily_report.created_at.localtime.strftime("%H:%M")
    }, status: :ok
  end

  # GET /daily_reports/new
  def new
    cash = 0
    credit_card = 0
    cheque = 0
    tranfers = 0
    total = 0
    start_time = nil
    start_time = DateTime.parse(params[:start_time]) if params[:start_time]
    start_time = DateTime.now if !start_time
    end_time = nil
    end_time = DateTime.parse(params[:end_time]) if params[:end_time]
    end_time = DateTime.now if !end_time
    invoice_ids = Invoice.where(created_at: start_time..end_time, invoice_status_id: InvoiceStatus.find_by_name('Active')).ids

    Invoice.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day)
    PaymentMethod.where(invoice_id: invoice_ids).each do |pm|
      if pm.payment_method == "เงินสด"
        cash += pm.amount
        total += pm.amount
      end

      if pm.payment_method == "บัตรเครดิต"
        credit_card += pm.amount
        total += pm.amount
      end

      if pm.payment_method == "เช็คธนาคาร"
        cheque += pm.amount
        total += pm.amount
      end

      if pm.payment_method == "เงินโอน"
        tranfers += pm.amount
        total += pm.amount
      end
    end

    render json: {
      cash: cash,
      credit_card: credit_card,
      cheque: cheque,
      tranfers: tranfers,
      total: total
    }, status: :ok
  end

  # POST /students
  def create
    @daily_report = DailyReport.new(daily_report_params)
    @daily_report.user_id = current_user.id
    @daily_report.save
    render json: @daily_report, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_daily_report
      @daily_report = DailyReport.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def daily_report_params
      params.require(:daily_report).permit(:real_start_cash, :real_cash, :real_credit_card, :real_cheque, :real_tranfers, :cash, :credit_card, :cheque, :tranfers)
    end
end
