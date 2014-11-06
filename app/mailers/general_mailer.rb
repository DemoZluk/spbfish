class GeneralMailer < ActionMailer::Base
  default from: I18n.t(:store_email)

  def report_error
    mail to: I18n.t(:store_email), subject: '[Test] Error report'
  end

  def feedback from, subject, body
    @feedback = body
    puts I18n.t(:store_email)
    mail to: I18n.t(:store_email), from: "FishMarkt<#{from}>", subject: "[FishMarkt] #{subject}"
  end
end
