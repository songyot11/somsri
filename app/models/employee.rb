class Employee < ApplicationRecord
  include ActiveModel::Dirty
  belongs_to :school
  has_many :emergency_calls, class_name: "Individual", foreign_key: 'emergency_call_id'
  has_many :spouses, class_name: "Individual", foreign_key: 'spouse_id'
  has_many :childs, class_name: "Individual", foreign_key: 'child_id'
  has_many :parents, class_name: "Individual", foreign_key: 'parent_id'
  has_many :friends, class_name: "Individual", foreign_key: 'friend_id'
  belongs_to :grade
  has_many :teacher_attendance_lists

  has_one :taxReduction

  has_many :payrolls
  after_create :create_tax_reduction
  before_create :new_payroll
  after_save :update_rollcall_list
  before_save :assign_pin
  after_destroy :delete_payroll

  acts_as_paranoid

  has_attached_file :img_url
  validates_attachment_content_type :img_url, content_type: /\Aimage\/.*\z/

  def assign_pin
    self.pin = get_unique_pin if !pin
  end

  @@warned = false
  def update_rollcall_list
    unless @@warned
      puts 'WARNING: please remove this function after rollcall list assignment has been implemented'
      @@warned = true
    end
    if self.classroom && !self.classroom.blank? && self.classroom_changed?
      # add or update list
      self.teacher_attendance_lists.destroy_all
      generate_teacher_attendance_lists
    elsif self.classroom.blank?
      # remove list
      self.teacher_attendance_lists.destroy_all
    end
  end

  def last_closed_payroll
    self.payrolls.where(closed: true).order(effective_date: :desc).first
  end

  def new_payroll
    self.payrolls << Payroll.new({ employee: self })
  end

  def delete_payroll
    Payroll.destroy_all(employee_id: self.id, closed: [false, nil])
  end

  def full_name
    if !self.first_name_thai.blank? && !self.last_name_thai.blank?
      [self.prefix_thai, self.first_name_thai, self.last_name_thai].join(" ")
    else
      [self.prefix, self.first_name, self.middle_name, self.last_name].join(" ")
    end
  end

  def lists
    list_ids = TeacherAttendanceList.where(employee_id: self.id).pluck(:list_id).to_a
    return List.where(id: list_ids).to_a
  end

  def annual_income_outcome(id)
    employee = Employee.with_deleted.find(id)

    year = employee.last_closed_payroll.effective_date.year
    start_year = Date.new(year, 1, 1)
    end_year = Date.new(year, 12, 31)

    payrolls = employee.payrolls.where(effective_date: start_year.beginning_of_day..end_year.end_of_day)

    return {
      total_salary: payrolls.as_json("report").inject(0) {
        |mem, var| mem + var[:salary] + var[:extra_pay] - var[:extra_fee]
      },
      total_tax: payrolls.sum(:tax),
      total_social_insurance: payrolls.sum(:social_insurance),
      total_aid_fund: payrolls.sum(:pvf)
    }
  end

  def as_json(options={})
    if options[:slip]
      result = {
        code: format("%05d", self.id),
        prefix: self.prefix,
        name: self.full_name,
        position: self.position,
        account_number: self.account_number,
        annual_income_outcome: self.annual_income_outcome(self.id)
      }

      # select payroll by payroll_id
      payroll = self.payroll(options[:payroll_id])
      if payroll
        result[:payroll] = payroll.as_json("slip")
        result[:extra_fee] = payroll.extra_fee.to_f
        result[:extra_pay] = payroll.extra_pay.to_f + payroll.salary.to_f
      else
        # default payroll
        result[:payroll] = self.last_closed_payroll.as_json("slip")
        result[:extra_fee] = self.last_closed_payroll.extra_fee.to_f
        result[:extra_pay] = self.last_closed_payroll.extra_pay.to_f + self.last_closed_payroll.salary.to_f
      end
      return result
    elsif options[:employee_list]
      has_last_closed_payroll = self.payrolls.size > 0 && self.last_closed_payroll
      {
        id: self.id,
        name: self.full_name,
        position: self.position,
        salary: has_last_closed_payroll ? self.last_closed_payroll.salary.to_f : 0,
        extra_fee: has_last_closed_payroll ? self.last_closed_payroll.extra_fee.to_f : 0,
        extra_pay: has_last_closed_payroll ? self.last_closed_payroll.extra_pay.to_f : 0,
        img: self.img_url.exists? ? self.img_url.url(:medium) : nil,
        deleted_at: self.deleted_at
      }
    else
      super()
    end
  end

  def lastest_payroll
     Payroll.where({ employee_id: self.id }).order(effective_date: :desc).first
  end

  def payroll(payroll_id)
    Payroll.where(employee_id: self.id, id: payroll_id).first
  end

  def tax_reduction
    TaxReduction.where(employee_id: self.id).first
  end

  def generate_teacher_attendance_lists
    if self.classroom
      TeacherAttendanceList.transaction do
        list = List.where(name: self.classroom).first
        if !list
          list = List.create(name: self.classroom, category: "roll_call")
          Student.where(classroom: self.classroom).pluck(:id).each do |student_id|
            StudentList.create(student_id: student_id, list_id: list.id)
          end
        else
          student_ids = Student.where(classroom: self.classroom).pluck(:id)
          exclude_student_ids = StudentList.where(list_id: list.id).pluck(:id)
          (student_ids - exclude_student_ids).each do |student_id|
            StudentList.create(student_id: student_id, list_id: list.id)
          end
        end

        if TeacherAttendanceList.where(employee_id: self.id, list_id: list.id).count == 0
          if TeacherAttendanceList.where(employee_id: self.id).count > 0
            TeacherAttendanceList.where(employee_id: self.id).destroy_all
          end
          TeacherAttendanceList.create(employee_id: self.id, list_id: list.id)
        end
      end
    end
  end

  def get_unique_pin
    pins = Employee.where.not(pin: nil).pluck(:pin).collect{|s| s.to_i}
    self.pin = ([*0..9999] - pins).sample.to_s.rjust(4, '0')
  end

  private
    def create_tax_reduction
      TaxReduction.create(employee_id: self.id)
    end

end
