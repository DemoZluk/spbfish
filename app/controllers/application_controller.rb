class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include CurrentCart
  before_action :set_cart, :authenticate_user!
  protect_from_forgery with: :exception
  after_action :no_cache
  #rescue ErrorReporter.report_error.deliver

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to store_url
  end

  def no_cache
    if request.xhr?
        response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
        response.headers["Pragma"] = "no-cache"
        response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end
  end

  def test_string string, mode = 'w+'
    File.open('tmp/test.txt', mode) do |f|
      f.puts "#{string}\n"
    end
  end

  protected
    
end
