class StoreController < ApplicationController
  include CurrentSettings

  before_action :change_user_prefs
  skip_before_action :authorize

  def visit_counter
    session[:counter] = (session[:counter]||0)+1
  end

  def index
    respond_to do |format|
      format.html
      format.js {render template: 'shared/product_index'}
    end
  end
end
