class AccountType < ApplicationRecord
  has_many :accounts

  def self.income
    1
  end

  def self.expenses
    2
  end

end
