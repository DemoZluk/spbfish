class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include CurrentCart
  before_action :set_cart, :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :exception
  #rescue ErrorReporter.report_error.deliver

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:account_update) << :login
    end
    
end
