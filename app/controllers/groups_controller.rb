class GroupsController < ApplicationController
  include CurrentSettings
  
  before_action :change_user_prefs
  skip_before_action :authorize, only: [:show]

  def show
    respond_to do |format|
      format.html
      format.js {render 'shared/product_index'}
    end

  end
end
