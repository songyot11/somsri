class Ability
  include CanCan::Ability

  def initialize(user)
    if user && user.admin?
      can :manage, :all
    elsif  user && user.finance_officer?
      can :manage, :menu
      can :manage, Invoice
      can :manage, DailyReport
      can :read, Grade
      can :read, Student
    end
  end

  def as_json(options={})
    manage = {}
    manage[:all] = true if self.can? :manage, :all
    manage[:menu] = true if self.can? :manage, :menu
    manage[:invoice] = true if self.can? :manage, Invoice
    manage[:daily_report] = true if self.can? :manage, DailyReport
    manage[:roll_call] = true if self.can? :manage, RollCall
    manage[:report_roll_call] = true if self.can? :manage, :report_roll_call
    result = {
      manage: manage
    }
    return result
  end
end
