class School < ApplicationRecord
  has_many :employees
  has_many :users
  has_attached_file :logo, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/somsri_logo.png"
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\z/

  def logo_url
    self.logo.expiring_url(3600, :medium)
  end

  def daily_report_header_with_logo
    if self.daily_report_header.present? && self.logo_url.present?
      return self.daily_report_header.gsub("_LOGO_URL_", self.logo_url)
    end
    return self.daily_report_header
  end

  def invoice_header_with_logo
    if self.invoice_header.present? && self.logo_url.present?
      return self.invoice_header.gsub("_LOGO_URL_", self.logo_url)
    end
    return self.invoice_header
  end

  def payroll_slip_header_with_logo
    if self.payroll_slip_header.present? && self.logo_url.present?
      return self.payroll_slip_header.gsub("_LOGO_URL_", self.logo_url)
    end
    return self.payroll_slip_header
  end
end
