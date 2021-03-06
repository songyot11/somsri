class Parent < ApplicationRecord
  include StudentsHelper
  include Rails.application.routes.url_helpers

  has_many :students_parents, dependent: :destroy
  has_and_belongs_to_many :students, join_table: "students_parents"
  has_and_belongs_to_many :relationships, join_table: "students_parents"
  has_many :invoices
  belongs_to :school

  acts_as_paranoid

  has_attached_file :img_url
  validates_attachment_content_type :img_url, content_type: /\Aimage\/.*\z/

  self.per_page = 10
  before_save :clean_full_name

  def clean_full_name
    self.full_name = self.full_name.strip.gsub(/\s+/,' ') if self.full_name
  end

  def self.search(search)
    Parent.joins(:students).where("parents.full_name LIKE ? OR parents.full_name_english LIKE ? OR parents.email LIKE ? OR parents.mobile LIKE ? OR students.full_name LIKE ? OR students.full_name_english LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%" , "%#{search}%" )
  end

  def self.search_by_name_and_mobile(search)
    Parent.where("parents.full_name LIKE ? OR parents.full_name_english LIKE ? OR parents.mobile LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%")
  end

  def invoice_screen_full_name_display
    if(mobile.to_s.strip != '')
      full_name + ' (' + mobile.to_s.strip + ')'
    else
      full_name
    end
  end

  def edit
    ActionController::Base.helpers.link_to I18n.t('.edit', :default => '<i class="fa fa-pencil-square-o" aria-hidden="true"></i> แก้ไข'.html_safe), edit_parent_path(self), :class => 'btn-edit-student-parent'
  end

  def relationship_names
    if self.respond_to?("name")
      self.name.nil? ? "" : I18n.t(self.name)
    else
      self.relationships.first.nil? ? "" : I18n.t(self.relationships.first.name)
    end
  end

  def studentFullname
    if self.respond_to?("student_name")
      self.student_name.nil? ? student_link(self.students.first) : student_link_by_hash(self.student_name.empty? ? Student.find_by(id: self.student_id)&.full_name_english : self.student_name, self.student_id)
    else
      student_link(self.students.first)
    end
  end

  def self.restore_by_student_id(student_id)
    parent_ids = StudentsParent.where(student_id: student_id).to_a.collect(&:parent_id)
    Parent.with_deleted.where(id: parent_ids).all.each do |parent|
      parent.restore_recursively
    end
  end

  def restore_recursively
    Parent.transaction do
      # restore all destroy by dependent: :destroy
      self.restore(recursive: true, recovery_window: 2.minutes)
    end
  end

  def as_json(options={})
    if options[:index]
      return {
        parents:{
          id: self.id,
          img_url: self.img_url.exists? ? self.img_url.expiring_url(10, :medium) : '',
          full_name: self.full_name,
          mobile: self.mobile,
          email: self.email,
        },
        relationships: {
          name: relationship_names
        },
        students: {
          full_name: studentFullname.nil? ? "" : studentFullname
        },
        edit: edit
      }
    elsif options[:autocomplete]
      return {
        full_name_label: self.invoice_screen_full_name_display,
        img_url: self.img_url.exists? ? self.img_url.expiring_url(10, :medium) : '',
        id: self.id
      }
    else
      super()
    end
  end
end
