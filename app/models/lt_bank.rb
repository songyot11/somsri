class LtBank < ApplicationRecord
  has_attached_file :image
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  has_many :banks , class_name: 'Bank', foreign_key: 'bank_id'
end
