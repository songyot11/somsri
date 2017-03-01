class Student < ApplicationRecord
  belongs_to :grade
  belongs_to :gender
  has_and_belongs_to_many :parents, join_table: 'students_parents'
  has_and_belongs_to_many :relationships, join_table: "students_parents"
  has_many :invoices
  self.per_page = 10

  validates :full_name , presence: true

  def full_name_with_title
    if gender_id != nil
      title = self.gender_id == 1  ? 'ด.ช.' : 'ด.ญ.'
      name = self.full_name.nil? ? self.full_name_english : self.full_name
      return "#{title} #{name}"
    else
      name = self.full_name.nil? ? self.full_name_english : self.full_name
      return "#{name}"
    end
  end

  def nickname_eng_thai
    if self.nickname && self.nickname.size > 0 && self.nickname_english && self.nickname_english.size > 0
      if self.nickname != self.nickname_english
        return "#{self.nickname} (#{self.nickname_english})"
      else
        return self.nickname
      end
    elsif self.nickname_english && self.nickname_english.size > 0
      return self.nickname_english
    else
      return self.nickname
    end
  end

  def get_nickname
    if self.nickname_english && self.nickname_english.size > 0
      return self.nickname_english
    else
      return self.nickname
    end
  end

  def grade_name
    if self.grade && self.classroom
      return "#{self.grade.name} (#{classroom})"
    elsif self.grade
      return self.grade.name
    else
      return ''
    end
  end

  def parent_names
    self.parents.collect(&:full_name).join(', ')
  end

  def active_invoice
    self.invoices.latest.is_a?(Invoice)? self.invoices.latest : nil
  end

  def active_invoice_status
    self.active_invoice.nil? ? 'ยังไม่ได้ชำระ' : (self.active_invoice.invoice_status.name == 'Active' ? 'ชำระแล้ว' : 'ยกเลิก')
  end

  def active_invoice_payment_method
    self.active_invoice.nil? ? '' : self.active_invoice.payment_methods.collect(&:payment_method).join(', ')
  end

  def active_invoice_entrance_fee
    self.active_invoice.nil? ? '' : self.active_invoice.entrance_fee
  end

  def active_invoice_total_amount
    self.active_invoice.nil? ? '' : self.active_invoice.total_amount
  end

  def active_invoice_updated_at
    self.active_invoice.nil? ? '' : self.active_invoice.updated_at
  end

  def self.search(search)
    where("full_name LIKE ? OR classroom LIKE ? OR nickname LIKE ? OR student_number::text LIKE ? OR classroom_number::text LIKE ? OR classroom LIKE ? ",
     "%#{search}%", "%#{search}%", "%#{search}%" , "%#{search}%" , "%#{search}%" , "%#{search}%" )
  end
end
