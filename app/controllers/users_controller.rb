class UsersController < ApplicationController
  require 'csv'

  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:new, :create]
  skip_authorize_resource only: [:show, :new, :create]
  respond_to :html, :js

  # # GET /users
  # # GET /users.json
  # def index
  #   @users = User.all.order('name')
  # end

  # # GET /users/1
  # # GET /users/1.json

  def index
    @users = User.all
  end

  def show
    if params[:id]
      @user = User.find(params[:id])
      authorize! :show, @user
    else
      @user = current_user
    end
  end

  def new
    @user.build_information
  end

  def create
    if verify_recaptcha
      @user = init_user_with data[:email]
      user_data = data.except(:email, :type)
      info = @user.create_information(user_data) if user_data.reject{|k,v| v.to_s.empty?}.any?
      puts @user.attributes
      if @user.save
        UsersMailer.notify_user(data, generated_password).deliver
        UsersMailer.new_user(data, @user).deliver
        redirect_to store_path, flash: {success: 'Учетная запись создана, но требует подтверждения с нашей стороны. Как только мы получим уведомление наш менеджер свяжется с Вами и подтвердит её.'}
      else
        render :new
      end
    else
      @user = User.new(email: data[:email])
      @user.build_information data.except(:email, :type)
      @user.errors.add :base, t(:recaptcha_failure)
      render :new
    end
  end

  def confirm
    user = User.find_by(confirmation_token: params[:t])

    if user.confirm!
      UsersMailer.confirmed(user).deliver
      redirect_to store_path, flash: {success: "Пользователь #{user.email} подтверждён"}
    end
  end

  def batch_create
    if params[:csv].present? && file = params[:csv].read
      @batch = {yes: 0, no: {}}
      CSV.parse(file).each do |row|
        email = row[0]
        user = init_user_with email
        if user.save
          @batch[:yes] += 1
        else
          @batch[:no][row[0]] = user.errors.full_messages
        end
      end
      puts @batch
      render :batch_create
    end
  end

  def init_user_with email
    generated_password = Devise.friendly_token.first(8)
    User.new(email: email, password: generated_password)
  end

  # # GET /users/new
  # def new
  #   @user = User.new
  # end

  # # GET /users/1/edit

  # # POST /users
  # # POST /users.json
  # def create
  #   @user = User.new(user_params)

  #   respond_to do |format|
  #     if @user.save
  #       format.html { redirect_to users_url, notice: I18n.t(:user_created, user_name: @user.name) }
  #       format.json { render action: 'show', status: :created, location: @user }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @user.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /users/1
  # # PATCH/PUT /users/1.json
  # def update
  #   respond_to do |format|
  #     if @user.update(user_params)
  #       format.html { redirect_to @user, notice: 'User was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: 'edit' }
  #       format.json { render json: @user.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  def add_data
    if info = current_user.information
      info.update(shipping_name: data[:name], shipping_address: data[:address], shipping_phone: data[:phone_number])
    else
      current_user.create_information(shipping_name: data[:name], shipping_address: data[:address], shipping_phone: data[:phone_number])
    end
    redirect_to user_root_path, notice: t('devise.registrations.updated')
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    begin
      user = User.find(params[:id])
      user.destroy
      flash[:notice] = I18n.t(:user_deleted, user_name: user.name)
    rescue Exeption => e
      flash[:notice] = e.message
    end
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private

    def data
      params.require(:information).permit(:phone_number, :address, :name, :email, :director, :contact, type: [])
    end
    # Use callbacks to share common setup or constraints between actions.

  #   # Never trust parameters from the scary internet, only allow the white list through.
  #   def user_params
  #     params.require(:user).permit(:name, :password, :password_confirmation)
  #   end
end
