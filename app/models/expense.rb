class Expense < ApplicationRecord
  acts_as_paranoid

  has_many :expense_items
  accepts_nested_attributes_for :expense_items
  before_save :clean_payment_method

  has_attached_file :img_url, styles: { medium: "300x300>", thumb: "100x100>" }
  validates_attachment_content_type :img_url, content_type: /\Aimage\/.*\z/

  def clean_payment_method
    if self.payment_method != "เช็คธนาคาร"
      self.cheque_bank_name = nil
      self.cheque_number = nil
      self.cheque_date = nil
    end
    if self.payment_method != "เงินโอน"
      self.transfer_bank_name = nil
      self.transfer_date = nil
    end
  end

  def self.search(keyword)
    if keyword.present?
      where("expenses_id ILIKE ? OR detail ILIKE ? ", "%#{keyword}%", "%#{keyword}%")
    else
      all
    end
  end
end
