class Parent < ApplicationRecord
  has_and_belongs_to_many :students, join_table: "students_parents"
  has_and_belongs_to_many :relationships, join_table: "students_parents"
  has_many :invoices
  self.per_page = 10

  def self.search(search)
    where("full_name LIKE ? OR full_name_english LIKE ? OR email LIKE ? OR mobile LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%" , "%#{search}%")
  end
end
