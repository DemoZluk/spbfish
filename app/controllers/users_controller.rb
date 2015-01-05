class UsersController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:new]
  skip_authorize_resource only: [:show, :new]
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
  end

  def create
    if verify_recaptcha
      generated_password = Devise.friendly_token.first(8)
      user = User.create!(email: data[:email], password: generated_password)
    else
      render :new
    end
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
      info.update(data)
    else
      current_user.create_information(data)
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
      params.require(:information).permit(:phone_number, :address, :name, :email)
    end
    # Use callbacks to share common setup or constraints between actions.

  #   # Never trust parameters from the scary internet, only allow the white list through.
  #   def user_params
  #     params.require(:user).permit(:name, :password, :password_confirmation)
  #   end
end
