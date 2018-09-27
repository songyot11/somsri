class Expense < ApplicationRecord
  acts_as_paranoid

  has_many :expense_items
  accepts_nested_attributes_for :expense_items

  has_attached_file :img_url, styles: { medium: "300x300>", thumb: "100x100>" }
  validates_attachment_content_type :img_url, content_type: /\Aimage\/.*\z/

  def self.search(keyword)
    if keyword.present?
      where("expenses_id ILIKE ? OR detail ILIKE ? ", "%#{keyword}%", "%#{keyword}%")
    else
      all
    end
  end
end
