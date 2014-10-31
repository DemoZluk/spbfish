class OrderNotifier < ActionMailer::Base
  default from: I18n.t(:from)
  @sign = I18n.t(:sign)
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_notifier.received.subject
  #
  def received order
    @order = order

    mail to: order.email.to_s, subject: "[FishMarkt] Ваш заказ №#{order.id} принят"
  end
  
  def order order
    @order = order
    mail to: 'mail@fishmarkt.ru', subject: "[Заказ №#{order.id}] Сделан пользователем #{order.name}"
  end

  def paid order, params
    @order = order
    @params = params
    mail to: 'mail@fishmarkt.ru', subject: "[Заказ №#{order.id}] Оплачен"
  end
  
  def canceled order
    @order = order
    mail to: "mail@fishmarkt.ru", subject: "[Заказ №#{order.id}] Отменён пользователем #{order.name}"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_notifier.shipped.subject
  #
  def shipped order
    @order = order
    mail to: order.email, subject: I18n.t(:mail_subject) + I18n.t(:order_shipped)
  end

  def confirmed order
    @order = order
    mail to: @order.email, subject: "[FishMarkt] Заказ № #{@order.id} подтверждён"
  end

  def update old, order
    @old = old
    @order = order
    mail to: 'mail@fishmarkt.ru', subject: "[Заказ  №#{@order.id}] обновлён", user_name: @order.name, order: @order.id
  end
end
