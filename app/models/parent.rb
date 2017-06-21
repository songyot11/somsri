class Parent < ApplicationRecord
  include StudentsHelper
  include Rails.application.routes.url_helpers

  has_and_belongs_to_many :students, join_table: "students_parents"
  has_and_belongs_to_many :relationships, join_table: "students_parents"
  has_many :invoices, dependent: :restrict_with_exception
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
    where("parents.full_name LIKE ? OR parents.full_name_english LIKE ? OR parents.email LIKE ? OR parents.mobile LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%" , "%#{search}%")
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

  def as_json(options={})
    if options[:index]
      return {
        full_name: self.full_name,
        mobile: self.mobile,
        email: self.email,
        relationships: {
          name: self.relationships.first.nil? ? "" : I18n.t(self.relationships.first.name)
        },
        students: {
          full_name: student_link_with_full_name(self.students.first) 
        },
        edit: edit
      }
    else
      super()
    end
  end
  
end
