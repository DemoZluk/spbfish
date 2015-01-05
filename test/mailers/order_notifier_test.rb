#encoding: utf-8
require 'test_helper'

class OrderNotifierTest < ActionMailer::TestCase
  test "received" do
    mail = OrderNotifier.received(orders(:one), 8753490)
    assert_equal "[spbfish] Подтверждение заказа", mail.subject
    assert_equal ["dave@example.org"], mail.to
    assert_equal ["mail@spbfish.ru"], mail.from
  end

  test "shipped" do
    mail = OrderNotifier.shipped(orders(:one))
    assert_equal "[spbfish] Отправка заказа", mail.subject
    assert_equal ["dave@example.org"], mail.to
    assert_equal ["mail@spbfish.ru"], mail.from
  end

end
