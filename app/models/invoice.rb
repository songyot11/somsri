class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :student
  belongs_to :parent
  belongs_to :invoice_status
  has_many :line_items
  has_many :payment_methods

  scope :latest, -> { order("created_at DESC").first }

  def total_amount
    self.line_items.collect(&:amount).inject(:+)
  end

  def entrance_fee
    entrance_fee = self.line_items.select{|l| (l.detail && l.detail.include?('entrance'))}.first
    entrance_fee.nil? ? 0 : entrance_fee.amount
  end

  def student_full_name_with_nickname
    name = self.student.full_name_with_title if self.student
    name = "#{name} (#{self.student.get_nickname})" if self.student && self.student.get_nickname
    return name
  end

  def parent_name
    self.parent.full_name if self.parent
  end

  def payee_name
    self.user.full_name if self.user
  end

  def payment_method_names
    self.payment_methods.collect(&:payment_method).join(', ')
  end

  def status_name
    self.invoice_status.name == 'Active' ? 'ชำระแล้ว' : 'ยกเลิก'
  end

  def is_cancel
    self.invoice_status.name == 'Canceled'
  end

  # def self.search(search)
  #   where("full_name LIKE ? OR classroom LIKE ? OR nickname LIKE ? OR student_number::text LIKE ? OR classroom_number::text LIKE ? OR classroom LIKE ? ",
  #    "%#{search}%", "%#{search}%", "%#{search}%" , "%#{search}%" , "%#{search}%" , "%#{search}%" )
  # end

end
