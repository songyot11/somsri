class LineItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :quotation
end
