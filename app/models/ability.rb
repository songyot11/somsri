class Ability
  include CanCan::Ability

  def initialize(user)
    case user
    when User
      if user.admin?
        can :access, :rails_admin
        can :dashboard
        can :manage, :all
        can :manage, SiteConfig
      elsif  user.finance_officer?
        can :manage, :menu
        can :manage, Invoice
        can :manage, DailyReport
        can :read, Grade
        can :manage, Student
        can :manage, Parent
        can :read, School
        can :manage, :setting
        can :manage, Classroom
        can :manage, Alumni
        can :read, SiteConfig
        can :manage, Expense
        can :manage, ExpenseTag
        can :manage, ExpenseTagItem
        can :manage, ExpenseItem
      end
    when Employee
      can :manage, :menu
      can :manage, Vacation, :requester_id => user.id
      if user.approver?
        can :manage, VacationConfig
        can [:approve, :reject], Vacation
      else
        can :read, VacationConfig
      end
    end
  end

  def as_json(options={})
    manage = {}
    manage[:all] = true if self.can? :manage, :all
    manage[:menu] = true if self.can? :manage, :menu
    manage[:invoice] = true if self.can? :manage, Invoice
    manage[:daily_report] = true if self.can? :manage, DailyReport
    manage[:roll_call] = true if self.can? :manage, RollCall
    manage[:expense] = true if self.can? :manage, Expense
    manage[:report_roll_call] = true if self.can? :manage, :report_roll_call
    manage[:student] = true if self.can? :manage, Student
    manage[:parent] = true if self.can? :manage, Parent
    manage[:setting] = true if self.can? :manage, :setting
    manage[:school] = true if self.can? :manage, School
    manage[:vacation] = true if self.can? :manage, Vacation
    manage[:vacation_config] = true if self.can? :manage, VacationConfig
    result = {
      manage: manage
    }
    return result
  end
end
