class User < ApplicationRecord
  self.table_name = "employees"
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :school
  has_many :invoices, dependent: :destroy
  has_one :tax_reduction, class_name: 'TaxReduction', foreign_key: 'employee_id'
  belongs_to :role
  delegate :can?, :cannot?, :to => :ability

  def ability
    Ability.new(self)
  end

  def employee
    Employee.find(self.id)
  end

  def account_holder?
    self.has_role? :account_holder
  end

  def admin?
    self.has_role? :admin
  end

  def finance_officer?
    self.has_role? :finance_officer
  end

  def human_resource?
    self.has_role? :human_resource
  end

  def employee?
    self.has_role? :employee
  end

  def procurement_officer?
    self.has_role? :procurement_officer
  end

  def teacher?
    self.has_role? :teacher
  end

  def approver?
    self.has_role? :approver
  end

end
