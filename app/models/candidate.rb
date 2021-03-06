class Candidate < ApplicationRecord

  acts_as_paranoid
  has_paper_trail
  has_many :programming_skills
  has_many :soft_skills
  has_many :design_skills
  has_many :candidate_files
  has_one :interview
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
        attention: helpers.link_to_path(attention, id),
        email: helpers.link_to_path(email, id),
        from: helpers.link_to_path(from, id),
        created_at: helpers.date_formatter(created_at),
        detail: helpers.link_to_path("รายละเอียด", id)
      }
    elsif(options['show_or_edit'])
      {
        id: id || '',
        full_name_and_nick_name: "#{full_name} (#{nick_name})",
        full_name: full_name || '',
        nick_name: nick_name || '',
        school_year: school_year || '',
        current_ability: current_ability || 10,
        learn_ability: learn_ability || 10,
        email: email || '',
        from: from || '',
        phone: phone || '',
        note: note || '',
        attention: attention || 10,
        interest: interest || '',
        created_at: created_at || '',
        image: "",
        image_url: image.expiring_url(10),
        deleted: deleted?,
        versions: versions.map{ |v| VersionUtil.with_user(v) },
        interview: interview.present? ? interview : Interview.new,
        programming_skills_attributes: self.new_record? ? [programming_skills.build.attributes.except('id')] : programming_skills,
        soft_skills_attributes: self.new_record? ? [soft_skills.build.attributes.except('id')] : soft_skills,
        design_skills_attributes: self.new_record? ? [design_skills.build.attributes.except('id')] : design_skills,
        candidate_files_attributes: self.new_record? ? [candidate_files.build.attributes.except('id')]   : candidate_files,
        candidate_files_url: candidate_files.map { |x| x.files },
        shortlist: shortlist
     }
    else
      super
    end
  end  
end