class Quotation < ApplicationRecord
  belongs_to :user
  belongs_to :student
  belongs_to :parent
  belongs_to :invoice
  has_many :line_items

  enum quotation_status: %i[unpaid active cancelled]

  def student_name
    student&.full_name_with_title
  end

  def grade_name
    student&.grade&.name
  end

  def quotator_name
    user&.full_name || user&.name
  end

  def total_amount
    line_items&.sum(&:amount) || 0
  end

  def paid_at
    invoice&.created_at
  end

  def outstanding_balance # ยอดค้างชำระ
    (invoice&.line_items&.sum(&:amount) || 0) - total_amount
  end
end
