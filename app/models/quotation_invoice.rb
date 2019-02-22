class QuotationInvoice < ApplicationRecord
  belongs_to :invoice
  belongs_to :quotation
end
