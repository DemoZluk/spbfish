class GroupsController < ApplicationController
  include CurrentSettings

  before_action :change_user_prefs, :set_group, :set_products
  skip_before_action :authenticate_user!, only: [:show]

  def show
    respond_to do |format|
      format.html
      format.js {@par = params[:p].to_a + params[:r].to_a; render 'store/index'}
    end
  end

  private

    def set_group
      @group = Group.find_by permalink: params[:id]
    end

    def set_products
      products = @group.all_products(@order_by)
      current_list_of products
    end
end
