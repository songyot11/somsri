class Account < ApplicationRecord
  belongs_to :account_type

  validates :name, presence: true
  validates :account_type_id, presence: true
  validates :date, presence: true
  validates :amount, presence: true

  scope :income, -> { where(account_type_id: AccountType.income) }
  scope :expenses, -> { where(account_type_id: AccountType.expenses) }
end
