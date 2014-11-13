class GeneralMailer < ActionMailer::Base
  default from: I18n.t(:store_email)

  def report_error
    mail to: I18n.t(:store_email), subject: '[Test] Error report'
  end

  def feedback from, subject, body
    @feedback = body
    mail to: I18n.t(:store_email), from: "FishMarkt<#{from}>", subject: "[FishMarkt] #{subject}"
  end

  def newsletter mailer
    @mailer = mailer
    mailer.subscriptions.each do |s|
      mail to: s.email, subject: mailer.subject, from: I18n.t(:store_email)
    end
  end
end
