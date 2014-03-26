class ErrorReporter < ActionMailer::Base
  default from: "mail@fishmarkt.ru"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.error_reporter.report_error.subject
  #
  def report_error
    mail to: 'mail@fishmarkt.ru', subject: '[Test] Error report'
  end
end
