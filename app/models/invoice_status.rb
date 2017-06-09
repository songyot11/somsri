class InvoiceStatus < ApplicationRecord
  def self.status_active_id
    where(name: 'Active').first.id
  end

  def self.status_canceled_id
    where(name: 'Canceled').first.id
  end
end
