class Ability
  include CanCan::Ability

  def initialize(user)
    # if user && user.school && user.school.id
    if user
      # can :manage, :all, school_id: user.school.id
      # can :manage, Employee, school_id: user.school.id
      # employees = Employee.where(school_id: user.school.id)
      # can :manage, Payroll, employee_id: employees
      # can :manage, :home
      # can :manage, :payrolls
      # can :manage, :setting
      # can :manage, Individual
      can :manage, :all
    else
      cannot :manage, :all
    end
  end
end
