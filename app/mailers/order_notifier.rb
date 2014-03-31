class OrderNotifier < ActionMailer::Base
  default from: I18n.t(:from)
  @sign = I18n.t(:sign)
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_notifier.received.subject
  #
  def received(order, total_price)
    @order = order
    @total_price = total_price

    mail to: order.email, subject: I18n.t(:mail_subject) + I18n.t(:order_received)
  end
  
  def order(order, total_price)
    @order = order
    @total_price = total_price
    mail to: 'mail@fishmarkt.ru', subject: "[#{I18n.t('active_record.models.order')}] " + t('.user_made_order', user_name: @order.name)
  end
  
  def order_canceled(order)
    @order = order
    mail to: "mail@fishmarkt.ru", subject: "[#{t('.active_record.models.order')}] " + t('.user_canceled_order', user_name: @order.name)
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_notifier.shipped.subject
  #
  def shipped(order)
    @order = order
    mail to: order.email, subject: I18n.t(:mail_subject) + I18n.t(:order_shipped)
  end
end
