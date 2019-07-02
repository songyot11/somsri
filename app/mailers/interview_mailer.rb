class InterviewMailer < ApplicationMailer
    default from: 'hr@bananacoding.com'

    def interview_notification(interview)

        mail(to: "", subject: "นัดสัมภาษณ์ ")
    end

    def edit_interview_notification(interview)

        mail(to: "", subject: "ขอแก้ไขนัดสัมภาษณ์  ")
    end

end