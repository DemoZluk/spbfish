class MailersController < ApplicationController
  include Redirect
  before_action :set_mailer, only: [:show, :edit, :update, :destroy, :start]
  respond_to :html, :js

  def index
    @mailers = Mailer.all
    respond_with(@mailers)
  end

  def show
    respond_with(@mailer)
  end

  def start
    GeneralMailer.newsletter(@mailer).deliver
    redirect_to action: 'show', notice: 'Рассылка запущена'
  end

  def new
    @mailer = Mailer.new
    respond_with(@mailer)
  end

  def edit
  end

  def create
    @mailer = Mailer.new(mailer_params)
    @mailer.save
    respond_with(@mailer)
  end

  def update
    @mailer.update(mailer_params)
    respond_with(@mailer)
  end

  def destroy
    @mailer.destroy
    respond_with(@mailer)
  end

  def subscribe
    mail = params[:email]
    success = false
    if params[:id]
      @mailer = Mailer.find(params[:id])
      success = true if @mailer.subscriptions.create(email: mail)
    else
      Mailer.all.each do |m|
        m.subscriptions.create(email: mail)
      end
      success = true
    end
    if success
      redirect_to store_path, flash: {success: "Вы успешно подписались на рассылк#{@mailer ? 'у' : 'и'}"}
    else
      redirect_to store_path, flash: {error: "Не удалось подписаться на рассылку"}
    end
  end

  def subscriptions
    if params[:t]
      sub = Subscription.find_by(token: params[:t])
      @subscriptions = Subscription.where{ email == sub.email }
    elsif user_signed_in?
      @subscriptions = current_user.subscriptions
    end
    @mailers = Mailer.all
    respond_with(@mailers)
  end

  def unsubscribe
    t = params[:t]
    @subscripted = Subscription.where{ token == t }
    render :index
  end

  private
    def set_mailer
      @mailer = Mailer.find(params[:id])
    end

    def mailer_params
      params.require(:mailer).permit(:title, :description, :subject, :body)
    end
end
