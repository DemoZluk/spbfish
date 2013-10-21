class ProductGroupsController < ApplicationController
  skip_before_action :authorize, only: [:index, :show]

  def show
    @group = ProductGroups.find_by_permalink(params[:id])
    current = session[:user][:prefs][:per_page] rescue 10
    @products = @group.products.order(params[:order_by] || 'title').page(params[:page]).per(current)
  end

end
