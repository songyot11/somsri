class Interview < ApplicationRecord
  belongs_to :candidate

  # def date
  #   return Date.today.strftime("%d/%m/%Y %H:%m")
  # end
end