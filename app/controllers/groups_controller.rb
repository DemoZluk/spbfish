class GroupsController < ApplicationController
  include CurrentSettings

  before_action :change_user_prefs, :set_group, :set_products
  skip_before_action :authorize, only: [:show]

  def show
    respond_to do |format|
      format.html
      format.js {render 'shared/product_index'}
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
