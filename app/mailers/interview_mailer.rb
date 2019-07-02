class InterviewMailer < ApplicationMailer
    default from: 'hr@bananacoding.com'

    def interview_notification(interview)
        @interview = interview
        mail(to: @interview.candidate.email, subject: "นัดสัมภาษณ์ #{@interview.candidate.full_name}")
    end

    def edit_interview_notification(interview)
        @interview = interview
        mail(to: @interview.candidate.email, subject: "ขอแก้ไขนัดสัมภาษณ์  #{@interview.candidate.full_name}")
    end

end