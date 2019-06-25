class CandidateFile < ApplicationRecord
    belongs_to :candidate
    accepts_nested_attributes_for :candidate
    has_attached_file :files, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: ""
    validates_attachment_content_type :files, content_type: /\Aimage\/.*\z/
    
    def files=(files = [])
        files.each{|f| (@files ||= []) << files.create(files: f) }
      end

  end