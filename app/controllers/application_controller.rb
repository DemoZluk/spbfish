class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include CurrentCart
  before_action :set_cart, :authenticate_user!
  protect_from_forgery with: :exception
  #rescue ErrorReporter.report_error.deliver

  protected

    def authorize
      unless session[:user_id] && User.find(session[:user_id])
        redirect_to login_url, notice: I18n.t(:please_log_in)
      end
    end
    
end
