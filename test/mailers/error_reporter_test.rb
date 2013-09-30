require 'test_helper'

class ErrorReporterTest < ActionMailer::TestCase
  test "should_report_error" do
    mail = ErrorReporter.report_error
    assert_equal '[Test] Error report', mail.subject
    assert_equal 'mail@spbfish.ru', mail.to
    assert_equal 'mail@spbfish.ru', mail.from
    assert_match 'Hi', mail.body.encoded
  end

end
