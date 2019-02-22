class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :school
  has_many :invoices, dependent: :destroy
  belongs_to :role
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
end
