class Candidate < ApplicationRecord
  acts_as_paranoid
  has_many :programming_skills
  has_many :soft_skills
  has_many :design_skills
  has_many :candidate_files
  accepts_nested_attributes_for :programming_skills, :soft_skills, :design_skills, :candidate_files, reject_if: :all_blank, allow_destroy: true
  has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "http://chittagongit.com/images/icon-file-size/icon-file-size-10.jpg"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
  has_attached_file :file, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :file, content_type: /\Aimage\/.*\z/
  def helpers
    ApplicationController.helpers
  end  

  def as_json(options = {})
    if options['data_table']
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
    elsif(options['joins-table'])
      {
        id: id,
        full_name: full_name,
        nick_name: nick_name,
        school_year: school_year,
        current_ability: current_ability,
        learn_ability: learn_ability,
        email: email,
        from: from,
        created_at: created_at,
        image: image.expiring_url(10),
        programming_skills_attributes: programming_skills,
        soft_skills_attributes: soft_skills,
        design_skills_attributes: design_skills,
        candidate_files_attributes: candidate_files,
        candidate_files_url: candidate_files.map { |x| x.files }
     }
    elsif options['show']
      {
        id: id,
        full_name_and_nick_name: "#{full_name} (#{nick_name})",
        email: email,
        phone_number: phone,
        from: from,
        school_year: school_year,
        current_ability: current_ability,
        learn_ability: learn_ability,
        attention_ability: attention,
        programming_skills: programming_skills,
        soft_skills: soft_skills,
        design_skills: design_skills,
        note: note    
      }
    else
      super
    end
  end  
end