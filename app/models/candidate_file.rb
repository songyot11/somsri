class CandidateFile < ApplicationRecord
    belongs_to :candidate
    has_attached_file :files, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: ""
    validates_attachment_content_type :files, content_type: /\Aimage\/.*\z/

  end