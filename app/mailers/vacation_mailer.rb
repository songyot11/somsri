class VacationMailer < ApplicationMailer

  def self.sick_leave_request(user, vacation)
    recipients = User.with_role(:admin)
    recipients.each do |recipient|
      send_sick_leave_request(recipient, user, vacation).deliver
    end
  end

  def send_sick_leave_request(recipient, user, vacation)
    @user = user
    @vacation = vacation
    setup_link(vacation)
    mail(to: recipient.email, subject: "#{@user.full_name} ยืนคำขอลาป่วย")
  end

  def self.vacation_leave_request(user, vacation)
    recipients = User.with_role(:admin)
    recipients.each do |recipient|
      send_vacation_leave_request(recipient, user, vacation).deliver
    end
  end

  def send_vacation_leave_request(recipient, user, vacation)
    @user = user
    @vacation = vacation
    setup_link(vacation)
    mail(to: recipient.email, subject: "#{@user.full_name} ยืนคำขอลากิจ")
  end

  def setup_link(vacation)
    @approve_url = "#{ENV['DEFAULT_SITE_URL']}/vacations/#{vacation.id}/approve"
    @reject_url = "#{ENV['DEFAULT_SITE_URL']}/vacations/#{vacation.id}/reject"
    @dashboard_url = "#{ENV['DEFAULT_SITE_URL']}/somsri#/vacation/dashboard/"
  end

end
