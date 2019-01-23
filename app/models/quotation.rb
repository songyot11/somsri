class Quotation < ApplicationRecord
  belongs_to :user
  belongs_to :student
  belongs_to :parent
  has_many :line_items
  has_many :line_item_quotations , dependent: :destroy

  has_many :quotation_invoices, dependent: :destroy
  has_many :invoices, through: :quotation_invoices

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
    line_item_quotations&.sum(&:amount) || 0
  end

  def paid_at
    invoices.last&.created_at
  end

  def outstanding_balance # ยอดค้างชำระ
    total = 0
    invoices.each do |invoice|
      total += invoice&.line_items&.sum(&:amount) || 0
    end
    return total - total_amount
  end

  def invoice_line_items
    invoice_line_item = []
    invoices.each do |invoice|
      invoice_line_item << {
        id: invoice.id,
        amount: invoice&.line_items&.sum(&:amount),
        created_at: invoice&.created_at&.strftime("%d/%m/%Y")
      }
    end
    return invoice_line_item
  end
end
