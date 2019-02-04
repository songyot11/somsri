class InvoiceStatus < ApplicationRecord
  def self.status_active_id
    status = where(name: 'Active').first
    if status
      return status
    else
      create(name: "Canceled")
      return create(name: "Active")
    end
  end

  def self.status_canceled_id
    status = where(name: 'Canceled').first
    if status
      return status
    else
      create(name: "Active")
      return create(name: "Canceled")
    end
  end
end
