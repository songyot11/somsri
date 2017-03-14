class Parent < ApplicationRecord
  has_and_belongs_to_many :students, join_table: "students_parents"
  has_and_belongs_to_many :relationships, join_table: "students_parents"
  has_many :invoices
  belongs_to :school
  self.per_page = 10

  def self.search(search)
    where("parents.full_name LIKE ? OR parents.full_name_english LIKE ? OR parents.email LIKE ? OR parents.mobile LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%" , "%#{search}%")
  end

  def invoice_screen_full_name_display
    if(mobile.to_s.strip != '')
      full_name + ' (' + mobile.to_s.strip + ')'
    else
      full_name
    end
  end
end
