class Candidate < ApplicationRecord
  acts_as_paranoid
  has_many :programming_skills
  has_many :soft_skills
  has_many :design_skills
  accepts_nested_attributes_for :programming_skills
  accepts_nested_attributes_for :soft_skills
  accepts_nested_attributes_for :design_skills
  has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "http://chittagongit.com/images/icon-file-size/icon-file-size-10.jpg"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
  has_attached_file :file, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :file, content_type: /\Aimage\/.*\z/
  def helpers
    ApplicationController.helpers
  end  

  def as_json(options = {})
    if(options['data-table'])
      {
      id: id,
      link_full_name: helpers.link_to_path(full_name, id),
      nick_name: helpers.link_to_path(nick_name, id),
      school_year: helpers.link_to_path(school_year, id),
      current_ability: helpers.link_to_path(current_ability, id),
      learn_ability: helpers.link_to_path(learn_ability, id),
      email: helpers.link_to_path(email, id),
      from: helpers.link_to_path(from, id),
      created_at: helpers.date_formatter(created_at),
      detail: helpers.link_to_path("รายละเอียด", id)
    }
    else
      super
    end
  end  
end