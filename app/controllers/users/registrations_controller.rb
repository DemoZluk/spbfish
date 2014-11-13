class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :html, :js
  before_action :set_mailers
  def create
    if verify_recaptcha
      super
    else
      build_resource(sign_up_params)
      clean_up_passwords(resource)
      resource.errors.add :base, t(:recaptcha_failure)
      render :new
    end
  end

  def edit
  end

  def set_mailers
    puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
  end
end