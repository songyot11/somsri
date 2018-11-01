class ExpenseTagItem < ApplicationRecord
  belongs_to :expense_tag
  belongs_to :expense_item
end
