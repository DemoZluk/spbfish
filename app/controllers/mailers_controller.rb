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

  private
    def set_mailer
      @mailer = Mailer.find(params[:id])
    end

    def mailer_params
      params.require(:mailer).permit(:title, :subject, :body)
    end
end
