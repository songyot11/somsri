class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :school
  has_many :invoices, dependent: :destroy
  belongs_to :role
  has_many :vacations
  delegate :can?, :cannot?, :to => :ability

  def ability
    Ability.new(self)
  end

  def admin?
    self.has_role? :admin
  end

  def finance_officer?
    self.has_role? :finance_officer
  end

  def leave_remaining
    sick_leave_count = self.vacations.sick_leave.count
    full_day_leave = self.vacations.vacation_full_day
    half_day_morning_leave = self.vacations.vacation_half_day_morning
    half_day_afternoon_leave = self.vacations.vacation_half_day_afternoon
    vacation_leave_count = full_day_leave.not_approved.count + half_day_morning_leave.not_approved.count + half_day_afternoon_leave.not_approved.count
    switch_date_count = self.vacations.switch_date.count
    work_at_home_count = self.vacations.work_at_home.count

    deduce_days = 0
    deduce_days += sick_leave_count * VacationType.sick_leave.deduce_days
    deduce_days += full_day_leave.not_approved.count * VacationType.vacation_full_day.deduce_days
    deduce_days += half_day_morning_leave.not_approved.count * VacationType.vacation_half_day_morning.deduce_days
    deduce_days += half_day_afternoon_leave.not_approved.count * VacationType.vacation_half_day_afternoon.deduce_days
    deduce_days += switch_date_count * VacationType.switch_date.deduce_days
    deduce_days += work_at_home_count * VacationType.work_at_home.deduce_days
    remaining_day = self.leave_allowance - deduce_days

    remaining_day
  end

end
