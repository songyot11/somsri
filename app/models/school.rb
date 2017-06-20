class School < ApplicationRecord
  has_many :employees
  has_many :users
  has_attached_file :logo, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/somsri_logo.png"
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\z/
end
