class Student < ApplicationRecord
  belongs_to :grade
  belongs_to :gender
  belongs_to :school
  has_and_belongs_to_many :parents, join_table: 'students_parents'
  has_and_belongs_to_many :relationships, join_table: "students_parents"
  has_many :invoices

  has_many :student_lists, dependent: :destroy
  alias_attribute :code, :student_number
  alias_attribute :number, :classroom_number
  attr_accessor :first_name, :last_name, :prefix

  self.per_page = 10

  validates :full_name , presence: true
  validates :student_number , uniqueness: true , allow_nil: true

  acts_as_paranoid
  
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

  def active_invoice_tuition_fee
    self.active_invoice.nil? ? '' : self.active_invoice.tuition_fee
  end

  def active_invoice_entrance_fee
    self.active_invoice.nil? ? '' : self.active_invoice.entrance_fee
  end

  def active_invoice_other_fee
    self.active_invoice.nil? ? '' : self.active_invoice.other_fee
  end

  def active_invoice_total_amount
    self.active_invoice.nil? ? '' : self.active_invoice.total_amount
  end

  def active_invoice_updated_at
    self.active_invoice.nil? ? '' : self.active_invoice.updated_at
  end

  def self.search(search)
    if search
      where("full_name ILIKE ? OR classroom ILIKE ? OR nickname ILIKE ? OR student_number::text ILIKE ? OR classroom_number::text ILIKE ? OR classroom ILIKE ? OR full_name_english ILIKE ? OR nickname_english ILIKE ? ",
       "%#{search}%", "%#{search}%", "%#{search}%" , "%#{search}%" , "%#{search}%" , "%#{search}%" , "%#{search}%" , "%#{search}%" )
    else
      all
    end
  end

  def first_name
    self.full_name.gsub(/\s+/m, ' ').strip.split(" ")[0]
  end

  def first_name=(value)
    full_name = self.full_name
    full_a = Array.new
    if !full_name.nil?
      full_a = full_name.gsub(/\s+/m, ' ').strip.split(" ")
    end
    full_a[0] = value
    self.full_name = "#{full_a.join(' ')}"
  end

  def last_name
    name_a = self.full_name.gsub(/\s+/m, ' ').strip.split(" ")
    if name_a.size > 2
      last_name_a = Array.new
      name_a.each_with_index do |n, index|
        if index > 0
          last_name_a.push(n)
        end
      end
      return "#{last_name_a.join(' ')}"
    else
      return "#{name_a[1]}"
    end
  end

  def last_name=(value)
    full_name = self.full_name
    full_a = full_name.gsub(/\s+/m, ' ').strip.split(" ")
    self.full_name = "#{full_a[0]} #{value}"
  end

  def prefix
    if self.gender_id == 1
      return "ด.ช."
    elsif self.gender_id == 2
      return "ด.ญ."
    else
      return ""
    end
  end

  def prefix=(value)
    if value == "ด.ช." || value.include?("ช")
      self.gender_id = 1
    elsif value == "ด.ญ." || value.include?("ญ")
      self.gender_id = 2
    else
      self.gender_id = nil
    end
  end

  def missing
    missingCount = 0
    dateStart = Time.now - Time.now.day.days + 1.days
    (0..(Time.now.day-2)).each do |i|
      date = dateStart + i.days
      rollcall = RollCall.where(check_date:date.strftime("%Y-%m-%d"))
      student_rollcall = rollcall.where(student_id:self.id, round:'morning').first

      if !student_rollcall.nil?
        missingCount += 1 if student_rollcall.status == "0"
        missingCount += 1 if student_rollcall.status == "1"
        missingCount += 1 if student_rollcall.status == "2"
      end
    end

    return missingCount
  end

  def roll_call
    RollCall.where(student_id:self.id)
  end

  def as_json(option={})
    roll_call_json = {
      id: self.id,
      code: self.code,
      first_name: self.first_name,
      last_name: self.last_name,
      prefix: self.prefix,
      number: self.number
    }
    return roll_call_json.merge(super())
  end

  def full_name_eng_thai_with_title
    title = self.gender_id == 1  ? 'ด.ช.' : 'ด.ญ.'
    thaiName = self.full_name.nil? ? "" : self.full_name
    engName = self.full_name_english.nil? ? "" : self.full_name_english

    if gender_id != nil && (full_name_english != "" && full_name_english != nil)
      return "#{title} #{thaiName} (#{engName})"
    else
      return "#{title} #{thaiName}"
    end
  end

  def invoice_screen_full_name_display
    if(nickname.to_s.strip != '')
      full_name_with_title + ' (' + nickname.to_s.strip + ')'
    else
      full_name_with_title
    end
  end

  def invoice_screen_student_number_display
    if(student_number)
      "#{student_number} - #{invoice_screen_full_name_display}"
    else
      invoice_screen_full_name_display
    end
  end

  def student_num
    self.student_number.nil? ? "-" : self.student_number
  end

end
