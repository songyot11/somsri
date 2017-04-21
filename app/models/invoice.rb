class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :student
  belongs_to :parent
  belongs_to :invoice_status
  has_many :line_items
  has_many :payment_methods

  self.per_page = 10

  scope :latest, -> { order("created_at DESC").first }

  def total_amount
    self.line_items.collect(&:amount).inject(:+)
  end

  def entrance_fee
    entrance_fee = self.line_items.select{|l| (l.detail && l.detail.include?('entrance'))}.first
    entrance_fee.nil? ? 0 : entrance_fee.amount
  end

  def other_fee
    self.line_items.collect{|item| item.amount unless item.detail =~ /Tuition Fee/ }.compact.inject(:+)
  end

  def tuition_fee
    self.line_items.collect{|item| item.amount if item.detail =~ /Tuition Fee/ }.compact.inject(:+)
  end

  def student_full_name_with_nickname
    self.student.invoice_screen_full_name_display if self.student
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

end
