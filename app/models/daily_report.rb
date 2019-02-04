class DailyReport < ApplicationRecord
  belongs_to :user
  def total
    cash + credit_card + cheque + tranfers
  end

  def real_total
    real_start_cash + real_cash + real_credit_card + real_cheque + real_tranfers
  end

end
