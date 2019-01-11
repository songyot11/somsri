class Quotation < ApplicationRecord
  belongs_to :user
  belongs_to :student
  belongs_to :parent
  has_many :line_items

  enum quotation_status: [:active, :cancel]
end
