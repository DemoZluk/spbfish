class SessionsController < ApplicationController
  skip_before_action :authorize
  
  def new
  end

  def create
    user = User.find_by_name(params[:name])
    if user 
      if user.authenticate(params[:password])
        session[:user_id] = user.id
        redirect_to admin_url
        else
        redirect_to login_url, alert: I18n.t(:invalid_password)
      end
    else
      redirect_to login_url, alert: I18n.t(:user_not_found, user_name: params[:name])
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to store_url, notice: I18n.t(:logged_out)
  end
end
