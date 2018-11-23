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
    self.vacations = self.vacations.this_year
    sick_leave_count = self.vacations.sick_leave.map(&:deduce_days).inject(0, &:+)
    full_day_leave_count = self.vacations.vacation_full_day.not_rejected.map(&:deduce_days).inject(0, &:+)
    half_day_morning_leave_count = self.vacations.vacation_half_day_morning.not_rejected.map(&:deduce_days).inject(0, &:+)
    half_day_afternoon_leave_count = self.vacations.vacation_half_day_afternoon.not_rejected.map(&:deduce_days).inject(0, &:+)
    switch_date_count = self.vacations.switch_date.map(&:deduce_days).inject(0, &:+)
    work_at_home_count = self.vacations.work_at_home.map(&:deduce_days).inject(0, &:+)

    deduce_days = 0
    deduce_days += sick_leave_count
    deduce_days += full_day_leave_count
    deduce_days += half_day_morning_leave_count
    deduce_days += half_day_afternoon_leave_count
    deduce_days += switch_date_count
    deduce_days += work_at_home_count
    remaining_day = self.leave_allowance - deduce_days

    i, f = remaining_day.to_i, remaining_day.to_f
    i == f ? i : f
  end

end
