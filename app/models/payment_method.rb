class PaymentMethod < ApplicationRecord
  belongs_to :invoice
end
