class EmployeesController < ApplicationController
  load_and_authorize_resource except: [:slip, :show, :payrolls, :calculate_deduction]
  skip_before_action :verify_authenticity_token, :only => [:update, :create, :destroy]

  # GET /employees
  def index
    employee = Employee.with_deleted.order('employees.deleted_at DESC ,employees.start_date ASC, employees.created_at ASC')
                              .as_json(employee_list: true)
    render json: employee, status: :ok
  end

  # GET /employees/:id/slip
  def slip
    authorize! :manage, Employee
    if Payroll.where({ employee_id: params[:id], closed: true }).count > 0
      employee = Employee.with_deleted.where(id: params[:id]).first.as_json({ slip: true, payroll_id: params[:payroll_id] })
      employee[:payroll][:fee_orders] = employee[:payroll][:fee_orders]
                                                        .select { |key, value| value[:value] > 0}
      employee[:payroll][:pay_orders] = employee[:payroll][:pay_orders]
                                                        .select { |key, value| value[:value] > 0}
      school = School.first
      employee[:header] = school.payroll_slip_header_with_logo || ""
      render json: employee, status: :ok
    else
      render json: [], status: :ok
    end
  end

  # GET /employees/slips
  def slips
    employees = []
    Payroll.where({ id: params[:payroll_ids] }).to_a.each do |payroll|
      employee = payroll.employee.as_json({ slip: true, payroll_id: payroll.id })
      employee[:payroll][:fee_orders] = employee[:payroll][:fee_orders]
                                                        .select { |key, value| value[:value] > 0}
      employee[:payroll][:pay_orders] = employee[:payroll][:pay_orders]
                                                        .select { |key, value| value[:value] > 0}
      school = School.first
      employee[:header] = school.payroll_slip_header_with_logo || ""
      employees << employee
    end

    respond_to do |format|
      format.html do
        render json: {
          employees: employees,
          one_per_page: SiteConfig.get_cache.one_slip_per_page
        }, status: :ok
      end
      format.pdf do
        @results = {
          employees: employees,
          one_per_page: SiteConfig.get_cache.one_slip_per_page
        }
        date = I18n.l(employees[0][:payroll][:date], format: "%d-%m-#{employees[0][:payroll][:date].year + 543}")
        render pdf: "ใบเสร็จเงินเดือน_#{date}",
                template: "pdf/slip.html.erb",
                encoding: "utf8",
                layout: 'pdf.html',
                show_as_html: params[:show_as_html].present?
      end
    end
  end

  # GET /employees/:id/payrolls
  def payrolls
    payrolls = Employee.with_deleted.find(params[:id]).payrolls
                       .order("created_at desc")
                       .as_json("history")
    render json: payrolls, status: :ok
  end

  # GET /employees/:id
  def show
    authorize! :manage, Employee
    @employee = Employee.with_deleted.find(params[:id])
    tax_reduction = @employee.tax_reduction
    if params[:payroll_id]
      payroll = @employee.payroll(params[:payroll_id])
    else
      payroll = @employee.lastest_payroll
    end

    vacationSetting = VacationSetting.where(school_id: @employee.school_id).first
    # Set default vacation day
    if @employee.sick_leave_maximum_days_per_year.nil? && !vacationSetting.nil?
      @employee.sick_leave_maximum_days_per_year = vacationSetting.sick_leave_maximum_days_per_year
    end
    if @employee.personal_leave_maximum_days_per_year.nil? && !vacationSetting.nil?
      @employee.personal_leave_maximum_days_per_year = vacationSetting.personal_leave_maximum_days_per_year
    end
    if @employee.switching_day_allow.nil? && !vacationSetting.nil?
      @employee.switching_day_allow = vacationSetting.switching_day_allow
    end
    if @employee.switching_day_maximum_days_per_year.nil? && !vacationSetting.nil?
      @employee.switching_day_maximum_days_per_year = vacationSetting.switching_day_maximum_days_per_year
    end
    if @employee.work_at_home_allow.nil? && !vacationSetting.nil?
      @employee.work_at_home_allow = vacationSetting.work_at_home_allow
    end
    if @employee.work_at_home_maximum_days_per_week.nil? && !vacationSetting.nil?
      @employee.work_at_home_maximum_days_per_week = vacationSetting.work_at_home_maximum_days_per_week
    end

    render json: {
      enable_rollcall: SiteConfig.get_cache.enable_rollcall,
      img_url: @employee.img_url.exists? ? @employee.img_url.expiring_url(10, :medium) : nil ,
      employee: @employee,
      employee_display_name: @employee.full_name,
      payroll: payroll,
      tax_reduction: tax_reduction,
      current_employee: current_user.employee?,
      vacationSetting: vacationSetting,
      current_admin: current_user.admin?,
      current_human_resource: current_user.human_resource?,
      has_last_salary: @employee.has_last_salary
    }
  end

  def create
    if current_user.present?
      vacationSetting = VacationSetting.where(school_id: current_user.school_id).first
      if !vacationSetting.nil?
        @employee.sick_leave_maximum_days_per_year = vacationSetting.sick_leave_maximum_days_per_year
        @employee.personal_leave_maximum_days_per_year = vacationSetting.personal_leave_maximum_days_per_year
        @employee.switching_day_allow = vacationSetting.switching_day_allow
        @employee.switching_day_maximum_days_per_year = vacationSetting.switching_day_maximum_days_per_year
        @employee.work_at_home_allow = vacationSetting.work_at_home_allow
        @employee.work_at_home_maximum_days_per_week = vacationSetting.work_at_home_maximum_days_per_week
      end
    end

    roles = params[:roles] || []
    if @employee.save
      user = User.find(@employee.id)
      roles.each do |role|
        user.add_role(role)
      end
      render json: {
        employee: @employee
      }, status: :ok
    else
      render json: @employee.errors, status: 500
    end
  end

  # POST /employees/:id/calculate_deduction
  def calculate_deduction
    p = JSON.parse(params[:payroll])
    e = Employee.with_deleted.find(params[:id])
    e.employee_type = params[:employee_type]
    e.pay_pvf = params[:employee_pay_pvf]
    e.pay_social_insurance = params[:employee_pay_s_ins]
    render json: {
      tax: Payroll.generate_tax(p, e),
      social_insurance: Payroll.generate_social_insurance(p, e),
      pvf: Payroll.generate_pvf(p, e)
    }, status: :ok
  end

  # PATCH /employees/:id
  def update
    roles = params[:role] || []

    user = User.find(@employee.id)
    user.roles = []
 
    employee_data = employee_params
    @employee.attributes = employee_data
    @employee.save
    
    roles.each do |role|
      user.add_role(role)
    end

    if params[:payroll]
      payroll_datas = payroll_params
      payroll_id = payroll_datas[:id]
      payroll_datas.delete(:id)
      payroll = Payroll.update(payroll_id, payroll_datas)
    end

    if params[:tax_reduction]
      tax_reduction_datas = tax_reduction_params
      tax_reduction_id = tax_reduction_datas[:id]
      tax_reduction = TaxReduction.update(tax_reduction_id, tax_reduction_datas)
    end

    render json: {
      img_url: @employee.img_url.exists? ? @employee.img_url.expiring_url(10, :medium) : nil ,
      employee: @employee,
      payroll: @employee.lastest_payroll,
      tax_reduction: @employee.tax_reduction
    }
  end

  # DELETE /employees/:id
  def destroy
    @employee.destroy
    data = {status: "success"}
    render json: data, status: :ok
  end

  def restore
    @employee = Employee.only_deleted.where(id: params[:employee_id]).update(deleted_at: nil)
    payroll = Payroll.only_deleted.where(employee_id: params[:employee_id]).update(deleted_at: nil)

    data = {status: "success"}
    render json: data, status: :ok
  end

  def real_destroy
    begin
      @employee = Employee.find(params[:employee_id])
      @employee.really_destroy!
    rescue ActiveRecord::DeleteRestrictionError => e
      @employee.errors.add(:base, e)
    ensure
      data = {status: "success"}
      render json: data, status: :ok
    end
  end

  def upload_photo
    @employee = Employee.where(id: params[:id]).update( img_url: upload_photo_params[:file] ).first
    @employee.reload
    render json: [{ url: @employee.img_url.expiring_url(10, :medium) }], status: :ok
  end

  def create_by_name
    fullname = params[:fullname]
    nickname = params[:nickname]

    name = Employee.split_name(fullname)
    name[:nickname] = nickname
    employee = Employee.create(name)
    result = {
      img: employee.img_url.exists? ? employee.img_url.expiring_url(10, :medium) : nil,
      name: employee.full_name_with_nickname,
      id: employee.id
    }
    render json: result, status: :ok
  end

  def me
    authorize! :manage, Employee
    @employee = Employee.with_deleted.find(current_user.id)
    tax_reduction = @employee.tax_reduction
    if params[:payroll_id]
      payroll = @employee.payroll(params[:payroll_id])
    else
      payroll = @employee.lastest_payroll
    end
    render json: {
      enable_rollcall: SiteConfig.get_cache.enable_rollcall,
      img_url: @employee.img_url.exists? ? @employee.img_url.expiring_url(10, :medium) : nil ,
      employee: @employee,
      employee_display_name: @employee.full_name,
      payroll: payroll,
      tax_reduction: tax_reduction,
      current_employee: current_user.employee?,
      current_admin: current_user.admin?,
      current_human_resource: current_user.human_resource?
    }
  end

  private
  def employee_params
    result = params.require(:employee).permit([
      :prefix_thai,
      :first_name_thai,
      :last_name_thai,
      :prefix,
      :first_name,
      :middle_name,
      :last_name,
      :position,
      :personal_id,
      :passport_number,
      :race,
      :nationality,
      :bank_name,
      :bank_branch,
      :account_number,
      :nickname,
      :start_date,
      :birthdate,
      :img_url,
      :employee_type,
      :address,
      :tel,
      :email,
      :status,
      :pay_pvf,
      :pay_social_insurance,
      :grade_id,
      :classroom_id,
      :password,
      :note,
      :comment,
      :sick_leave_maximum_days_per_year,
      :personal_leave_maximum_days_per_year,
      :switching_day_allow,
      :switching_day_maximum_days_per_year,
      :work_at_home_allow,
      :work_at_home_maximum_days_per_week
    ]).to_h
    return result
  end

  def payroll_params
    skips = ["id", "note", "employee_id"]
    result = params.require(:payroll).permit([
      :id,
      :employee_id,
      :salary,
      :allowance,
      :attendance_bonus,
      :ot,
      :bonus,
      :position_allowance,
      :extra_etc,
      :absence,
      :late,
      :tax,
      :social_insurance,
      :fee_etc,
      :pvf,
      :note,
      :advance_payment
    ])
    result.to_h.each do |k,v|
      result[k] = 0 if (!(skips.include? k) && v.blank?)
    end
    return result
  end

  def tax_reduction_params
    result = params.require(:tax_reduction).permit([
      :id,
      :employee_id,
      :pension_insurance,
      :pension_fund,
      :government_pension_fund,
      :private_teacher_aid_fund,
      :retirement_mutual_fund,
      :national_savings_fund,
      :expenses,
      :no_income_spouse,
      :child,
      :father_alimony,
      :spouse_father_alimony,
      :cripple_alimony,
      :father_insurance,
      :insurance,
      :spouse_insurance,
      :long_term_equity_fund,
      :social_insurance,
      :double_donation,
      :donation,
      :other,
      :mother_alimony,
      :spouse_mother_alimony,
      :mother_insurance,
      :spouse_father_insurance,
      :spouse_mother_insurance,
      :house_loan_interest
    ])
    result.to_h.each { |k,v| result[k] = 0 if k != "id" && v.blank? }
    return result
  end

  def upload_photo_params
    params.require(:employee).permit(:file)
  end
end
