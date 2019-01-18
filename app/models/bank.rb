class Bank < ApplicationRecord
  belongs_to :lt_bank, class_name: "LtBank", foreign_key: "bank_id"
end
