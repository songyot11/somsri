class LtBank < ApplicationRecord
  has_many :banks , class_name: 'Bank', foreign_key: 'bank_id'
end
