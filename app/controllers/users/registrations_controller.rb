class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :html, :js

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
end