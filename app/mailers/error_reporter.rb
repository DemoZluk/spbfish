class ErrorReporter < ActionMailer::Base
  default from: "mail@spbfish.ru"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.error_reporter.report_error.subject
  #
  def report_error
    mail to: 'mail@spbfish.ru', subject: '[Test] Error report'
  end
end
