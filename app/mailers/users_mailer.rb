class UsersMailer < ActionMailer::Base

  def new_user data, user
    @data = data
    @user = user
    mail to: I18n.t(:store_email), subject: "[Новый пользователь] #{@data[:name] || user.email}", from: @data[:email]
  end

  def notify_user data, pass
    @pass = pass
    @data = data
    mail to: data[:email], subject: "[Spbfish.ru] Регистрация на сайте spbfish.ru", from: I18n.t(:store_email)
  end

  def confirmed user
    mail to: user.email, subject: "[Spbfish.ru] Подтверждение учётной записи на сайте spbfish.ru", from: I18n.t(:store_email)
  end
end
