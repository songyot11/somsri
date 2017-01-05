class Ability
  include CanCan::Ability

  def initialize(user)
    if user && user.school && user.school.id
      # can :manage, :all, school_id: user.school.id
      can :manage, Employee, school_id: user.school.id
      employees = Employee.where(school_id: user.school.id)
      can :manage, Payroll, employee_id: employees
      can :manage, :home
      can :manage, :report
      can :manage, :setting
    else
      cannot :manage, :all
    end
  end
end
